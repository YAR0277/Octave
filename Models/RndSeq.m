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
    Sinput        % reference to Sinput class - the input structure for random sequences
    WhiteNoise    % reference to WhiteNoise class
    NoiseType     % type of white noise {'Exponential','Gaussian'}
    x             % a random sample of the random sequence
    X             % random sequence matrix
  endproperties

  methods % Public

    function obj = RndSeq(sinput)
      % c'tor to create a Returns object, input is an Sinput object.

      if nargin ~= 1
        error('c''tor: RndSeq(y) where y = instance of class Sinput.');
      endif

      if ~isa(sinput, 'Sinput')
        error('c''tor: RndSeq(y) where y = instance of class Sinput.');
      endif

      pkg load statistics;

      obj.Sinput = sinput;
      obj.WhiteNoise = WhiteNoise(sinput);
      obj.fcnNormRnd = @(m,s,n) normrnd(m,s,[1,n]);
      obj.fcnBernRnd = @(p,n) binornd(1,p,[1,n]);
      obj.fcnBinoRnd = @(m,p,n) binornd(m,p,[1,n]);
    endfunction

    function [r] = get.NoiseType(this)
      r = this.WhiteNoise.NoiseType;
    endfunction

    function [] = set.NoiseType(this,type)
      this.WhiteNoise.NoiseType = type;
    endfunction

    function [r] = get.WhiteNoise(this)
      r = this.WhiteNoise;
    endfunction

    function [] = set.WhiteNoise(this,o)
        this.WhiteNoise = o;
    endfunction

    function [] = GenerateSequence(this)
    % [] = GenerateSequence() generates random process
      this.X = zeros(this.Sinput.Height,this.Sinput.Length);
      tic
      for i=1:this.Sinput.Height
        this.X(i,:) = this.GenerateSample();
      endfor
      toc
    endfunction

    function [x] = GenerateSample(this)
    % [] = GenerateSample() generates a random sample
        switch this.Sinput.Type
          case "Constant"
            x = this.GenerateSampleConstant();
          case "Bernoulli"
            x = this.GenerateSampleBernoulli();
          case "RandomWalk"
            x = this.GenerateSampleRandomWalk();
          case "GaussMarkov"
            x = this.GenerateSampleGaussMarkov();
          case "WhiteNoise"
            x = this.GenerateSampleWhiteNoise();
          case "Wiener"
            x = this.GenerateSampleWiener();
          otherwise
        endswitch
        this.x = x; % update random sample
    endfunction

    function [] = Plot(this)
    % [] = Plot() plots first 20 of random process
      if isempty(this.X)
        error('generate seqence data by calling GenerateSequence.');
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

    function [] = PlotSample(this)
    % [] = PlotSample() plots sample of random process
      if isempty(this.x)
        error('generate sample data by calling GenerateSample.');
      endif

      figure;
      hold on;
      plot(this.x,'--.');
      hold off;
      grid on;
      grid minor;
    endfunction

    function [] = Stats(this)
      % [] = Stats() calculates statistics of random process
      if isempty(this.X)
        error('generate seqence data by calling GenerateSequence.');
      endif

      fprintf('Number of Sequences: %d\n',size(this.X,1));
      fprintf('Sequence Range: [%.2f,%.2f]\n',min(min(this.X)),max(max(this.X)));
      fprintf('Sequence Mean: %.2f\n',mean(mean(this.X)));
      fprintf('Sequence Std. Dev.: %.2f\n',std(std(this.X)));
      fprintf('Sequence Var.: %.2f\n',var(var(this.X)));
    endfunction

    function [r] = StatsSample(this)
      % [] = StatsSample() calculates statistics of a random sequence sample
      if isempty(this.x)
        error('generate sample data by calling GenerateSample.');
      endif

      fprintf('Number of Samples: %d\n',numel(this.x));
      fprintf('Sample Range: [%.2f,%.2f]\n',min(this.x),max(this.x));
      fprintf('Sample Mean: %.2f\n',mean(this.x));
      fprintf('Sample Std. Dev.: %.2f\n',std(this.x));
      fprintf('Sample Var.: %.2f\n',var(this.x));
    endfunction

    function [] = PlotDistr(this)
      % [] = PlotDistr() plots distribution
      if strcmpi(this.Sinput.Type,'RandomWalk') == 0
        error('method only implemented for input type Random Walk.');
      endif

      n = this.Sinput.Length;
      p = this.Sinput.PrbSuccess;
      x=-n:2:n;
      for k=1:numel(x)
        a = (n+x(k))/2;
        b = (n-x(k))/2;
        y(k) = nchoosek(n,a)*(p)^a*(1-p)^b;
      endfor

      figure;
      plot(x,y,'--.');
      titleStr = 'Random Walk Distribution';
      title(titleStr);
    endfunction
  endmethods % Public

  methods (Access = private)
    function [r] = GenerateSampleConstant(this)
      % generates a Constant sequence of length n.
      n = this.Sinput.Length;
      s2 = this.Sinput.Var;
      r = ones(n,1)*this.fcnNormRnd(0,sqrt(s2),1);
    endfunction

    function [r] = GenerateSampleBernoulli(this)
      % generates a Bernoulli sequence of length n with success probability p.
      n = this.Sinput.Length;
      p = this.Sinput.PrbSuccess;
      r = this.fcnBernRnd(p,n);
    endfunction

    function [x] = GenerateSampleRandomWalk(this)
        n = this.Sinput.Length;
        u = sqrt(this.Sinput.Var);
        w = this.fcnNormRnd(0,u,n);
        for i=1:n
          if i==1
            x(i) = this.Sinput.Initval;
          else
            x(i) = x(i-1) + this.Sinput.Drift + w(i); % Random walk with drift
          end
        endfor
    endfunction

    function [x] = GenerateSampleGaussMarkov(this)
      % generates Gauss-Markov sequence of length N, spacing dt.
      n = this.Sinput.Length;
      dt = this.Sinput.Timestep; % time interval between samples
      s2 = this.Sinput.Var; % variance of the Markov process
      beta = this.Sinput.Beta; % reciprocal time constant of the process
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

    function [r] = GenerateSampleWhiteNoise(this)
    % generates a White sequence using the WhiteNoise object.
      r = this.WhiteNoise.GenerateSample;
    endfunction

    function [x] = GenerateSampleWiener(this)
      % generates Wiener sequence with variance s2.
      n = this.Sinput.Length;
      x = zeros(1,n);
      s2 = this.Sinput.Var;
      w = this.fcnNormRnd(0,sqrt(s2),n); % white sequence N(0,s2)
      for i=1:n
        if (i==1)
          x(i)=0; % Wiener sequence, x(0)=0.
        else
          x(i) = x(i-1) + w(i); % [2], (P2.35)
        endif
      endfor
    endfunction
  endmethods % Private
endclassdef
