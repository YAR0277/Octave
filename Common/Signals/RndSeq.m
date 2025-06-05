classdef RndSeq < handle
  % class to handle Random Sequences
  %
  % References:
  % [1] Schaum's Outline Probability, Random Variables & Random Processes, H. Hsu
  % [2] Introduction to Random Signals, R.Brown
  %
  properties
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

      obj.sinput = sinput;
    endfunction

    function [] = GenSeq(this)
      this.X = zeros(this.sinput.height,this.sinput.length);
      tic
      for i=1:this.sinput.height
        this.X(i,:) = this.GetSample();
      endfor
      toc
    endfunction

    function [] = PlotSeq(this)
      % just do the first 20...
      figure;
      hold on;
      for i=1:20
        plot(this.X(i,:),'--.');
      endfor
      hold off;
    endfunction

    function [x] = GetSample(this)
      switch this.sinput.type
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
      figure;
      switch this.sinput.type
        case "Bernoulli"
          x = this.GetSampleBernoulli();
          this.PlotSampleBernoulli(x);
        case "RandomWalk"
          x = this.GetSampleRandomWalk();
          this.PlotSampleRandomWalk(x);
        case "GaussMarkov"
          x = this.GetSampleGaussMarkov();
          this.PlotSampleGaussMarkov(x);
        case "White"
          x = this.GetSampleWhite();
          this.PlotSampleWhite(x);
        case "Wiener"
          x = this.GetSampleWiener();
          this.PlotSampleWiener(x);
        otherwise
      endswitch
      this.x = x; % update random sample
    endfunction

    function [r] = ProcessStats(this,k)
      % calculates statistics of random process
      if isempty(this.X)
        fprintf('The random sequence is empty. Please generate a random sequence and try again.\n');
        return;
      endif

      ts = this.TheoreticalStats(k);

      fprintf('Number of Sequences: %d\n',size(this.X,1));
      fprintf('Sequence Max.: %.2f\n',max(this.X(:,k)));
      fprintf('Sequence Min.: %.2f\n',min(this.X(:,k)));
      fprintf('Sequence Mean: Actual (%.2f), Theoretical (%.2f)\n',mean(this.X(:,k)),ts.mean);
      fprintf('Sequence Std. Dev.: Actual (%.2f), Theoretical (%.2f)\n',std(this.X(:,k)),sqrt(ts.variance));
      fprintf('Sequence Var.: Actual (%.2f), Theoretical (%.2f)\n',var(this.X(:,k)),ts.variance);
    endfunction

    function [r] = SampleStats(this)
      % calculates statistics of a random sequence sample
      if isempty(this.x)
        fprintf('The random sample is empty. Please generate a sample and try again.\n');
        return;
      endif

      fprintf('Number of Samples: %d\n',numel(this.x));
      fprintf('Sample Max.: %.2f\n',max(this.x));
      fprintf('Sample Min.: %.2f\n',min(this.x));
      fprintf('Sample Mean: %.2f\n',mean(this.x));
      fprintf('Sample Std. Dev.: %.2f\n',std(this.x));
      fprintf('Sample Var.: %.2f\n',var(this.x));
    endfunction

    function [r] = TheoreticalStats(this,k)
      r = struct('mean',0,'variance',0);
      switch this.sinput.type
        case "RandomWalk" % [1], (P5.10)
          r.mean = this.sinput.length*(this.sinput.prbSuccess - (1 - this.sinput.prbSuccess)); % n(p-q);
          r.variance = 4*this.sinput.length*(this.sinput.prbSuccess*(1 - this.sinput.prbSuccess)); % 4npq
        case "Wiener" % [2], p101-102
          r.mean = 0; % (2.13.2)
          r.variance = k; % (2.13.4)
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

    function [r] = GetSampleBernoulli(this)
      % generates a Bernoulli sequence of length n with success probability p.
      n = this.sinput.length;
      p = this.sinput.prbSuccess;
      r = binornd(1,p,1,n);
    endfunction

    function [r] = GetSampleRandomWalk(this)
        z = this.GetSampleBernoulli();
        % replace 0 -> -1
        z(z==0) = z(z==0) - 1;
        % a random walk is such that X(0) = 0, so set the first one to be zero.
        n = this.sinput.length;
        for i=1:n+1
          if i==1
            r(i) = 0;
          else
            r(i) = sum(z(1:i-1));
          end
        endfor
    endfunction

    function [r] = GetSampleGaussMarkov(this)
      % generates Gauss-Markov sequence of length N, spacing dt.
      n = this.sinput.length;
      dt = this.sinput.timestep;
      s2 = this.sinput.var;
      beta = this.sinput.beta;
      a = s2*(1-exp(-2*beta*dt));

      this.sinput.SetVar(sqrt(a)); % set the variance of the white sequence
      W = this.GetSampleWhite();

      r=zeros(1,n); % Gauss-Markov process
      for k=1:n;
        if (k==1)
          r(k) = normrnd(0,s2);
        else
          r(k) = exp(-beta*dt)*r(k-1) + W(k);
        endif
      end
    endfunction

    function [r] = GetSampleWhite(this)
    % generates a Gaussian White sequence from N(0,s2).
      n = this.sinput.length;
      fcn = @(m,s,n) normrnd(m,s,[1,n]);

      s2 = this.sinput.var;
      r = fcn(0,s2,n); % white sequence N(0,s2)
    endfunction

    function [x] = GetSampleWiener(this)
      % generates Wiener sequence with variance s2.
      n = this.sinput.length;
      r=zeros(1,n);
      s2 = this.sinput.var;
      w=normrnd(0,s2,[1,n]);
      for i=1:n
        if (i==1)
          x(i)=0; % Wiener sequence, x(0)=0.
        else
          x(i) = x(i-1) + w(i);
        endif
      endfor
    endfunction

    function [] = PlotSampleBernoulli(this,x)
      stem(x);
      title('Sample - Bernoulli Process');
    endfunction

    function [] = PlotSampleRandomWalk(this,x)
      plot(x,'--.');
      title('Sample - Random Walk Sequence');
      grid on;
      grid minor;
    endfunction

    function [] = PlotSampleGaussMarkov(this,x)
      plot(x,'.');
      title('Sample - Gauss-Markov Sequence');
      grid on;
    endfunction

    function [] = PlotSampleWhite(this,x)
      plot(x,'.');
      title('Sample - Gaussian White Noise Sequence');
      grid on;
    endfunction

    function [] = PlotSampleWiener(this,x)
      plot(x,'.');
      title('Sample - Wiener Sequence');
      grid on;
    endfunction

  endmethods % Private
endclassdef
