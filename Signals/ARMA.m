classdef ARMA < handle
  % class to handle ARMA Sequences
  %
  % References:
  % [1] https://en.wikipedia.org/wiki/Autoregressive_moving-average_model
  % [2] Optimal Filtering, Anderson & Moore
  % [3] Introduction to Random Signals, R.Brown
  %
  properties
    K     % number of time steps, i.e. k=1,...,K.
    pAR   % params AR
    pMA   % params MA
    x0    % initial condition vector px1
    zAR   % output equation for AR process
    zMA   % output equation for MA process
    zARMA % values of ARMA process
  endproperties

  methods % Public

    function obj = ARMA(varargin)
      % c'tor to create an ARMA object, inputs are optionally p and q.

      switch nargin
        case 0
          obj.pAR = [1,1];
          obj.pMA = 0;
          obj.K = 100;
        case 1
          obj.pAR = varargin{1};
          obj.pMA = 0;
          obj.K = 100;
        case 2
          obj.pAR = varargin{1};
          obj.pMA = varargin{2};
          obj.K = 100;
        case 3
          obj.pAR = varargin{1};
          obj.pMA = varargin{2};
          obj.K = varargin{3};
        otherwise
          fmt = ['c''tor: ARMA() or ARMA(p,q) where p = order of AR, q = order of MA.','\n'];
          fprintf(fmt);
          return;
      endswitch

      obj.SetIC(zeros(length(obj.pAR),1)); % default IC

      pkg load statistics;

    endfunction

    function [r] = DoAR(this,pAR)

      if nargin < 2 || isempty(pAR)
        fmt = ['call is \"DoAR(pAR)\" where pAR is a vector of params of the AR process .\n'];
        fprintf(fmt);
        return;
      endif

      this.Clear(); % ensures only 1 nonzero vector process vector (zAR,zMA,zARMA), used in Stats.

      r = zeros(this.K,1); % result
      n = length(pAR); % dimension of AR process
      w = this.GetNoise();
      A = this.GetMatrixAR(pAR);
      B = [1;zeros(n-1,1)];
      X = zeros(n,this.K); % state equation matrix

      for k = 1:this.K
        if k==1
          X(:,k) = A*this.x0 + B*w(k);
        else
          X(:,k) = A*X(:,k-1) + B*w(k);
        endif
        r(k) = -pAR*X(:,k) + w(k);
      endfor

      this.zAR = r; % save for later
    endfunction

    function [r] = DoMA(this,pMA)

      if nargin < 2 || isempty(pMA)
        fmt = ['call is \"DoMA(pMA)\" where pMA is a vector of params of the MA process .\n'];
        fprintf(fmt);
        return;
      endif

      this.Clear();

      r = zeros(this.K,1); % result
      n = length(pMA); % dimension of AR process
      w = this.GetNoise();
      A = this.GetMatrixMA(pMA);
      B = [zeros(n-1,1);1];
      X = zeros(n,this.K); % state equation matrix

      for k = 1:this.K
        if k==1
          X(:,k) = A*this.x0 + B*w(k);
        else
          X(:,k) = A*X(:,k-1) + B*w(k);
        endif
        r(k) = pMA*X(:,k) + w(k);
      endfor

      this.zMA = r; % save for later
    endfunction

    function [] = DoARMA(this,pAR,pMA,v)

      if nargin < 4
        if isempty(pAR) || isempty(pMA)
          fmt = ['call is \"DoARMA(pAR,pMA)\" where pAR (pMA) is a vector of params of the AR (MA) process, respectively .\n'];
          fprintf(fmt);
          return;
        endif
        v = 1; % default variance for Gaussian white sequence
      endif

      this.Clear();
      this.zARMA = arma_rnd(pAR,pMA,v,this.K);

    endfunction

    function [] = SetIC(this,x0)
      % the dimension of the initial condition, x0, must equal p.
      this.x0 = x0;
    endfunction

    function [] = Plot(this)

      if (any(this.zAR) == 0) && (any(this.zMA) == 0) && (any(this.zARMA) == 0)
        fmt = ['generate process data by calling DoAR, DoMA or DoARMA.\n'];
        fprintf(fmt);
        return;
      endif

      if (any(this.zAR) == 1)
        this.PlotAR;
      elseif (any(this.zMA) == 1)
        this.PlotMA;
      elseif (any(this.zARMA) == 1)
        this.PlotARMA;
      endif
    endfunction

    function [r] = Stats(this)
      % calculates statistics of random process

      if (any(this.zAR) == 0) && (any(this.zMA) == 0) && (any(this.zARMA) == 0)
        fmt = ['generate process data by calling DoAR, DoMA or DoARMA.\n'];
        fprintf(fmt);
        return;
      endif

      if (any(this.zAR) == 1)
        x = this.zAR;
      elseif (any(this.zMA) == 1)
        x = this.zMA;
      elseif (any(this.zARMA) == 1)
        x = this.zARMA;
      endif

      fprintf('Number of sequence values: %d\n',size(x,1));
      fprintf('Sequence Range: [%.2f,%.2f]\n',min(x),max(x));
      fprintf('Sequence Mean: %.2f\n',mean(x));
      fprintf('Sequence Std. Dev.: %.2f\n',std(x));
      fprintf('Sequence Var.: %.2f\n',var(x));
    endfunction

  endmethods % Public

  methods (Access = private)

    function [] = Clear(this)
      this.zAR = zeros(this.K,1);
      this.zMA = zeros(this.K,1);
      this.zARMA = zeros(this.K,1);
    endfunction

    function [A] = GetMatrixAR(this,pAR)
      n = length(pAR);
      A = zeros(n);

      if n==1
        A = 1;
        return;
      endif

      A = [-pAR(1:n-1), -pAR(n);...
           eye(n-1), zeros(n-1,1)];
    endfunction

    function [A] = GetMatrixMA(this,pMA)
      n = length(pMA);
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
      s.SetLength(this.K);
      s.SetType('White');
      rs=RndSeq(s);
      r= rs.GetSample();
    endfunction

    function [] = PlotARMA(this)

      if isempty(this.zARMA)
        fmt = ['generate process data by calling DoARMA.\n'];
        fprintf(fmt);
        return;
      endif

      figure;
      hold on;
      plot([1:this.K],this.zARMA,'--.');
      hold off;
      grid on;
      grid minor;
    endfunction

    function [] = PlotAR(this)
      if isempty(this.zAR)
        fmt = ['generate process data by calling DoAR.\n'];
        fprintf(fmt);
        return;
      endif

      figure;
      hold on;
      plot([1:this.K],this.zAR,'--.');
      hold off;
      grid on;
      grid minor;
    endfunction

    function [] = PlotMA(this)
      if isempty(this.zMA)
        fmt = ['generate process data by calling DoMA.\n'];
        fprintf(fmt);
        return;
      endif

      figure;
      hold on;
      plot([1:this.K],this.zMA,'--.');
      hold off;
      grid on;
      grid minor;
    endfunction
  endmethods % Private
endclassdef
