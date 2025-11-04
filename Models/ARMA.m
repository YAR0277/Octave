classdef ARMA < handle
  % class to handle ARMA Sequences
  %
  % References:
  % [1] https://en.wikipedia.org/wiki/Autoregressive_moving-average_model
  % [2] Optimal Filtering, Anderson & Moore
  % [3] Introduction to Random Signals, R.Brown
  %
  properties
    NumTimesteps % number of time steps, i.e. k=1,...,K.
    ParamAR % AR parameters
    ParamMA % MA parameters
    Var % variance of Gaussian White Noise process
    X0  % initial condition
    zARMA % values of ARMA process
  endproperties

  methods % Public

    function obj = ARMA()
      % c'tor to create an ARMA object, inputs are optionally p and q.

      obj.ParamAR = [1];
      obj.ParamMA = [];
      obj.NumTimesteps = 100;
      obj.Var = 1;
      obj.X0 = zeros(length(obj.ParamAR),1);

      pkg load statistics;
      pkg load tsa; % time series analysis
    endfunction

    function [r] = get.NumTimesteps(this)
      r = this.NumTimesteps;
    endfunction

    function [] = set.NumTimesteps(this,n)
      this.NumTimesteps = n;
    endfunction

    function [r] = get.ParamAR(this)
      r = this.ParamAR;
    endfunction

    function [] = set.ParamAR(this,v)
      this.ParamAR = v;
      this.X0 = zeros(length(v),1);
    endfunction

    function [r] = get.ParamMA(this)
      r = this.ParamMA;
    endfunction

    function [] = set.ParamMA(this,v)
      this.ParamMA = v;
      this.X0 = zeros(length(v),1);
    endfunction

    function [r] = get.Var(this)
      r = this.Var;
    endfunction

    function [] = set.Var(this,v)
      this.Var = v;
    endfunction

    function [r] = get.X0(this)
      r = this.X0;
    endfunction

    function [] = set.X0(this,v)
      this.X0 = v;
    endfunction

    function [r] = GetTimestamp(this)
      % [r] = GetTimestamp() returns values of the time variable.
      r = [1:this.NumTimesteps];
    end

    function [r] = GetValue(this)
      % [r] = GetValue() returns values of the random process.
      r = this.zARMA;
    end

    function [] = Calc(this)
      % [] = Calc() calculates the random process.
      if ~isempty(this.ParamAR) && ~isempty(this.ParamMA)
        this.DoARMA;
      elseif ~isempty(this.ParamAR) && isempty(this.ParamMA)
        this.DoAR;
      elseif isempty(this.ParamAR) && ~isempty(this.ParamMA)
        this.DoMA;
      endif
    endfunction

    function [] = Clear(this)
      % [] = Clear() clears random process vectors.
      this.zARMA = zeros(this.NumTimesteps,1);
    endfunction

    function [] = Plot(this)
      % [] = Plot() plots random process.
      if (any(this.zAR) == 0) && (any(this.zMA) == 0) && (any(this.zARMA) == 0)
        error('generate process data by calling Calc');
      endif

      t = this.GetTimestamp;
      x = this.GetValue;

      this.DoPlot(t,x);
    endfunction

    function [] = Stats(this)
      % [] = Stats() calculates statistics of random process.

      if (any(this.zAR) == 0) && (any(this.zMA) == 0) && (any(this.zARMA) == 0)
        error('generate process data by calling Calc');
      endif

      x = this.GetValue;

      fprintf('Number of sequence values: %d\n',size(x,1));
      fprintf('Sequence Range: [%.2f,%.2f]\n',min(x),max(x));
      fprintf('Sequence Mean: %.2f\n',mean(x));
      fprintf('Sequence Std. Dev.: %.2f\n',std(x));
      fprintf('Sequence Var.: %.2f\n',var(x));
    endfunction

  endmethods % Public

  methods (Access = private)

    function [r] = DoAR(this)
    % [] = DoAR() generate autoregression sequence.
      ParamAR = this.ParamAR;
      if isempty(ParamAR)
        error('parameters for autoregression (ParamAR) empty.');
      endif

      this.Clear(); % ensures only 1 nonzero vector process vector (zAR,zMA,zARMA), used in Stats.

      r = zeros(this.NumTimesteps,1); % result
      n = length(ParamAR); % dimension of AR process
      w = this.GetNoise();
      A = this.GetMatrixAR(ParamAR);
      B = [1;zeros(n-1,1)];
      X = zeros(n,this.NumTimesteps); % state equation matrix

      if size(A,2) ~= size(this.X0,1)
        error('Matrix column dimension (%d) must equal initial condition row dimension (%d).',size(A,2),size(this.X0,1));
      endif

      for k = 1:this.NumTimesteps
        if k==1
          X(:,k) = A*this.X0 + B*w(k);
        else
          X(:,k) = A*X(:,k-1) + B*w(k);
        endif
        r(k) = -ParamAR*X(:,k) + w(k);
      endfor

      this.zARMA = r; % save for later
    endfunction

    function [r] = DoMA(this)
    % [] = DoMA() generate moving average sequence.
      ParamMA = this.ParamMA;
      if isempty(ParamMA)
        error('parameters for moving average (ParamMA) empty.');
      endif

      this.Clear();

      r = zeros(this.NumTimesteps,1); % result
      n = length(ParamMA); % dimension of AR process
      w = this.GetNoise();
      A = this.GetMatrixMA(ParamMA);
      B = [zeros(n-1,1);1];
      X = zeros(n,this.NumTimesteps); % state equation matrix

      for k = 1:this.NumTimesteps
        if k==1
          X(:,k) = A*this.X0 + B*w(k);
        else
          X(:,k) = A*X(:,k-1) + B*w(k);
        endif
        r(k) = ParamMA*X(:,k) + w(k);
      endfor

      this.zARMA = r; % save for later
    endfunction

    function [] = DoARMA(this)
      % [] = DoARMA() generate ARMA sequence.
      a = this.ParamAR;
      b = this.ParamMA;
      v = this.Var;
      t = this.NumTimesteps;

      if isempty(a) || isempty(b) || isempty(v)
        error('some parameters for ARMA model empty.');
      endif

      this.Clear();
      this.zARMA = arma_rnd(a,b,v,t);
    endfunction

    function [] = DoPlot(this,t,x)
      figure;
      hold on;
      plot(t,x,'--.');
      hold off;
      grid on;
      grid minor;
    endfunction

    function [A] = GetMatrixAR(this,ParamAR)
      % see [2], p.17
      n = length(ParamAR);
      A = zeros(n);

      if n==1
        A = 1;
        return;
      endif

      A = [-ParamAR(1:n-1), -ParamAR(n);...
           eye(n-1), zeros(n-1,1)];
    endfunction

    function [A] = GetMatrixMA(this,ParamMA)
      % see [2], p.17
      n = length(ParamMA);
      A = zeros(n);

      if n==1
        A = 0;
        return;
      endif

      A = [zeros(n-1,1), eye(n-1);...
           0, zeros(1,n-1)];
    endfunction

    function [r] = GetNoise(this)
      s=Sinput;
      s.Length=this.NumTimesteps;
      s.Type='White';
      s.Var=this.Var;
      rs=RndSeq(s);
      r= rs.GetSample();
    endfunction
  endmethods % Private
endclassdef
