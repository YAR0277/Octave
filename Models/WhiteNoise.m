classdef WhiteNoise < handle
  % class to handle White Noise Sequences
  %
  % References:
  % [1] Schaum's Outline Probability & Statistics, M. Spiegel
  %
  properties
    fcnExpoRnd    % function normrnd(mu,sigma,[sz])
    fcnNormRnd    % function normrnd(mu,sigma,[sz])
    Lambda        % lambda of exponential distribution
    Sinput        % reference to Sinput class - the input structure for random sequences
    NoiseType     % type of white noise {'Exponential','Gaussian'}
    x             % a random sample of the random sequence
    X             % random sequence matrix
  endproperties

  methods % Public

    function obj = WhiteNoise(sinput)
      % c'tor to create a WhiteNoise object, input is an Sinput object.

      if nargin ~= 1
        error('c''tor: WhiteNoise(y) where y = instance of class Sinput.');
      endif

      if ~isa(sinput, 'Sinput')
        error('c''tor: WhiteNoise(y) where y = instance of class Sinput.');
      endif

      pkg load statistics;

      obj.Sinput = sinput;
      obj.fcnExpoRnd = @(m,n) exprnd(m,[1,n]);
      obj.fcnNormRnd = @(m,s,n) normrnd(m,s,[1,n]);
      obj.Lambda = 1; % default
      obj.NoiseType = 'Gaussian';
    endfunction

    function [r] = get.NoiseType(this)
      r = this.NoiseType;
    endfunction

    function [] = set.NoiseType(this,type)
      if ismember(type,{'Exponential','Gaussian'})
        this.NoiseType = type;
      end
    endfunction

    function [r] = GetSample(this)
      r = this.x;
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
        switch this.NoiseType
          case 'Exponential'
            n = this.Sinput.Length;
            m = this.Lambda;
            x = this.fcnExpoRnd(m,n); % White exponential
          case 'Gaussian'
            n = this.Sinput.Length;
            s2 = this.Sinput.Var;
            x = this.fcnNormRnd(0,sqrt(s2),n); % White Gaussian N(0,s2)
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
      % calculates statistics of a random sequence sample
      if isempty(this.x)
        error('generate sample data by calling GenerateSample.');
      endif

      fprintf('Number of Samples: %d\n',numel(this.x));
      fprintf('Sample Range: [%.2f,%.2f]\n',min(this.x),max(this.x));
      fprintf('Sample Mean: %.2f\n',mean(this.x));
      fprintf('Sample Std. Dev.: %.2f\n',std(this.x));
      fprintf('Sample Var.: %.2f\n',var(this.x));
    endfunction

  endmethods % Public
endclassdef
