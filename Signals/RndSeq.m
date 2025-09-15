classdef RndSeq < handle
  % class to handle Random Sequences
  %
  % References:
  % [1] Schaum's Outline Probability, Random Variables & Random Processes, H. Hsu
  % [2] Introduction to Random Signals, R.Brown
  %
  properties
    fcnNormRnd    % function normrnd(mu,sigma,[sz])
    fcnBernRnd    % function binornd(1,p,[sz]), i.e. Bernoulli r.v.
    fcnBinoRnd    % function binornd(n,p,[sz])
    sinput        % reference to Sinput class - the input structure for random sequences
    x             % a random sample of the random sequence
    X             % random sequence matrix
  endproperties

  methods % Public

    function obj = RndSeq(sinput)
      % c'tor to create a Returns object, input is an Finput object.

      if nargin ~= 1
        fmt = ['c''tor: RndSeq(y) where y = instance of class Sinput.','\n'];
        fprintf(fmt);
        return;
      endif

      if ~isa(sinput, 'Sinput')
        return;
      endif

      pkg load statistics;

      obj.sinput = sinput;
      obj.fcnNormRnd = @(m,s,n) normrnd(m,s,[1,n]);
      obj.fcnBernRnd = @(p,n) binornd(1,p,[1,n]);
      obj.fcnBinoRnd = @(m,p,n) binornd(m,p,[1,n]);
    endfunction

    function [] = GenerateSequence(this)
      this.X = zeros(this.sinput.height,this.sinput.length);
      tic
      for i=1:this.sinput.height
        this.X(i,:) = this.GetSample();
      endfor
      toc
    endfunction

    function [] = Plot(this)

      if isempty(this.X)
        this.GenerateSequence(); % generate the sequence
      endif

      % just do the first 20...
      figure;
      hold on;
      for i=1:20
        plot(this.X(i,:),'--.');
      endfor
      hold off;
      grid on;
      grid minor;
    endfunction

    function [x] = GetSample(this)
      switch this.sinput.type
        case "Constant"
          x = this.GetSampleConstant();
        case "Bernoulli"
          x = this.GetSampleBernoulli();
        case "RandomWalk"
          x = this.GetSampleRandomWalk();
        case "GaussMarkov"
          x = this.GetSampleGaussMarkov();
        case "White"
          x = this.GetSampleWhite();
        case "Wiener"
          x = this.GetSampleWiener();
        otherwise
      endswitch
      this.x = x; % update random sample
    endfunction

    function [] = PlotSample(this)

      if isempty(this.x)
        this.GenerateSample();
      endif

      figure;
      switch this.sinput.type
        case "Constant"
          this.PlotSampleConstant(this.x);
        case "Bernoulli"
          this.PlotSampleBernoulli(this.x);
        case "RandomWalk"
          this.PlotSampleRandomWalk(this.x);
        case "GaussMarkov"
          this.PlotSampleGaussMarkov(this.x);
        case "White"
          this.PlotSampleWhite(this.x);
        case "Wiener"
          this.PlotSampleWiener(this.x);
        otherwise
      endswitch
    endfunction

    function [r] = Stats(this,k)
      % calculates statistics of random process

      if nargin ~= 2
        fmt = ['call: Stats(k) where k = time index.','\n'];
        fprintf(fmt);
        return;
      endif

      if isempty(this.X)
        this.GenerateSequence(); % generate the sequence
      endif

      ts = this.TheoreticalStats(k);

      fprintf('Number of Sequences: %d\n',size(this.X,1));
      fprintf('Sequence Range: [%.2f,%.2f]\n',min(this.X(:,k)),max(this.X(:,k)));
      fprintf('Sequence Mean: Actual (%.2f), Theoretical (%.2f)\n',mean(this.X(:,k)),ts.mean);
      fprintf('Sequence Std. Dev.: Actual (%.2f), Theoretical (%.2f)\n',std(this.X(:,k)),sqrt(ts.variance));
      fprintf('Sequence Var.: Actual (%.2f), Theoretical (%.2f)\n',var(this.X(:,k)),ts.variance);
    endfunction

    function [r] = SampleStats(this)
      % calculates statistics of a random sequence sample
      if isempty(this.x)
        this.GenerateSample();
      endif

      fprintf('Number of Samples: %d\n',numel(this.x));
      fprintf('Sample Range: [%.2f,%.2f]\n',min(this.x),max(this.x));
      fprintf('Sample Mean: %.2f\n',mean(this.x));
      fprintf('Sample Std. Dev.: %.2f\n',std(this.x));
      fprintf('Sample Var.: %.2f\n',var(this.x));
    endfunction

    function [r] = TheoreticalStats(this,k)

      if nargin ~= 2
        fmt = ['call: TheoreticalStats(k) where k = time index.','\n'];
        fprintf(fmt);
        return;
      endif

      r = struct('mean',0,'variance',0);
      switch this.sinput.type
        case "Constant" % [2], (Ex.2.5)
          r.mean = 0;
          r.variance = this.sinput.var;
        case "RandomWalk" % [1], (P5.10)
          r.mean = k*(this.sinput.prbSuccess - (1 - this.sinput.prbSuccess)); % k(p-q);
          r.variance = 4*k*(this.sinput.prbSuccess*(1 - this.sinput.prbSuccess)); % 4kpq
        case "Wiener" % [1], 5.7
          r.mean = 0; % (5.62)
          r.variance = (this.sinput.var)*k; % (5.63)
        case "GaussMarkov"
          r.mean = 0; % (??)
          r.variance = 0; % ?? ()
        case "White"
          r.mean = 0;
          r.variance = (this.sinput.var);
        otherwise
      endswitch
    endfunction

    function [] = PlotDistr(this)
      switch this.sinput.type
        case "RandomWalk" % [1], (P5.8)
          titleStr = 'Random Walk Distribution';
          n = this.sinput.length;
          p = this.sinput.prbSuccess;
          x=-n:2:n;
          for k=1:numel(x)
            a = (n+x(k))/2;
            b = (n-x(k))/2;
            y(k) = nchoosek(n,a)*(p)^a*(1-p)^b;
          endfor
      endswitch
      figure;
      plot(x,y,'--.');
      title(titleStr);
    endfunction
  endmethods % Public

  methods (Access = private)

    function [] = GenerateSample(this)
        switch this.sinput.type
          case "Constant"
            x = this.GetSampleConstant();
          case "Bernoulli"
            x = this.GetSampleBernoulli();
          case "RandomWalk"
            x = this.GetSampleRandomWalk();
          case "GaussMarkov"
            x = this.GetSampleGaussMarkov();
          case "White"
            x = this.GetSampleWhite();
          case "Wiener"
            x = this.GetSampleWiener();
          otherwise
        endswitch
        this.x = x; % update random sample
    endfunction

    function [r] = GetSampleConstant(this)
      % generates a Constant sequence of length n.
      n = this.sinput.length;
      s2 = this.sinput.var;
      r = ones(n,1)*this.fcnNormRnd(0,sqrt(s2),1);
    endfunction

    function [r] = GetSampleBernoulli(this)
      % generates a Bernoulli sequence of length n with success probability p.
      n = this.sinput.length;
      p = this.sinput.prbSuccess;
      r = this.fcnBernRnd(p,n);
    endfunction

    function [r] = GetSampleRandomWalk(this)
        z = this.GetSampleBernoulli();
        % replace 0 -> -1
        z(z==0) = z(z==0) - 1;
        % a random walk is such that X(0) = 0, so set the first one to be zero.
        n = this.sinput.length;
        for i=1:n
          if i==1
            r(i) = 0;
          else
            r(i) = sum(z(1:i-1));
          end
        endfor
    endfunction

    function [x] = GetSampleGaussMarkov(this)
      % generates Gauss-Markov sequence of length N, spacing dt.
      n = this.sinput.length;
      dt = this.sinput.timestep; % time interval between samples
      s2 = this.sinput.var; % variance of the Markov process
      beta = this.sinput.beta; % reciprocal time constant of the process
      a = s2*(1-exp(-2*beta*dt));
      x = zeros(1,n);
      w = this.fcnNormRnd(0,sqrt(a),n);
      for k=1:n;
        if (k==1)
          x(k) = this.fcnNormRnd(0,sqrt(s2),1);
        else
          x(k) = exp(-beta*dt)*x(k-1) + w(k);
        endif
      end
    endfunction

    function [r] = GetSampleWhite(this)
    % generates a Gaussian White sequence from N(0,s2).
      n = this.sinput.length;
      s2 = this.sinput.var;
      r = this.fcnNormRnd(0,sqrt(s2),n); % white sequence N(0,s2)
    endfunction

    function [x] = GetSampleWiener(this)
      % generates Wiener sequence with variance s2.
      n = this.sinput.length;
      x = zeros(1,n);
      s2 = this.sinput.var;
      w = this.fcnNormRnd(0,sqrt(s2),n); % white sequence N(0,s2)
      for i=1:n
        if (i==1)
          x(i)=0; % Wiener sequence, x(0)=0.
        else
          x(i) = x(i-1) + w(i); % [2], (P2.35)
        endif
      endfor
    endfunction

    function [] = PlotSampleConstant(this,x)
      plot(x,'--.');
      title('Sample from Constant Process');
    endfunction

    function [] = PlotSampleBernoulli(this,x)
      plot(x,'--.');
      title('Sample from Bernoulli Process');
    endfunction

    function [] = PlotSampleRandomWalk(this,x)
      plot(x,'--.');
      title('Sample from Random Walk Sequence');
      grid on;
      grid minor;
    endfunction

    function [] = PlotSampleGaussMarkov(this,x)
      plot(x,'.');
      title('Sample from Gauss-Markov Sequence');
      grid on;
    endfunction

    function [] = PlotSampleWhite(this,x)
      plot(x,'.');
      title('Sample from Gaussian White Noise Sequence');
      grid on;
    endfunction

    function [] = PlotSampleWiener(this,x)
      plot(x,'.');
      title('Sample from Wiener Sequence');
      grid on;
    endfunction

  endmethods % Private
endclassdef
