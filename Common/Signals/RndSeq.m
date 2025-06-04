classdef RndSeq < handle

  properties
    sinput        % reference to Sinput class
    x             % the random sequence
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

    function [r] = GetSeq(this)
      switch this.sinput.type
        case "Bernoulli"
          r = this.GetBernoulli();
        case "RandomWalk"
          r = this.GetRandomWalk();
        case "GaussMarkov"
          r = this.GetGaussMarkov();
        case "White"
          r = this.GetWhiteSequence();
        case "Wiener"
          r = this.GetWienerSequence();
        otherwise
      endswitch
    endfunction

    function [] = PlotSeq(this)
      switch this.sinput.type
        case "Bernoulli"
          this.PlotBernoulli();
        case "RandomWalk"
          this.PlotRandomWalk();
        case "GaussMarkov"
          this.PlotGaussMarkov();
        case "White"
          this.PlotWhiteSequence();
        case "Wiener"
          this.PlotWienerSequence();
        otherwise
      endswitch
    endfunction

    function [r] = Stats(this)
      % calculates statistics on random sequence
      if isempty(this.x)
        fprintf('The random sequence is empty. Please generate random sequence and try again.\n');
        return;
      endif

      fprintf('Number of Samples: %d\n',numel(this.x));
      fprintf('Max.: %.2f\n',max(this.x));
      fprintf('Min.: %.2f\n',min(this.x));
      fprintf('Mean.: %.2f\n',mean(this.x));
      fprintf('Std. Dev.: %.2f\n',std(this.x));
      fprintf('Var.: %.2f\n',var(this.x));
    endfunction

  endmethods % Public

  methods (Access = private)

    function [r] = GetBernoulli(this)
      % generates a Bernoulli sequence of length n with success probability p.
      n = this.sinput.length;
      p = this.sinput.prbSuccess;
      r = binornd(1,p,1,n);
      this.x = r; % store for Stats method
    endfunction

    function [r] = GetRandomWalk(this)
        z = this.GetBernoulli();
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
        this.x = r;
    endfunction

    function [r] = GetGaussMarkov(this)
      % generates Gauss-Markov sequence of length N, spacing dt.
      n = this.sinput.length;
      dt = this.sinput.timestep;
      s2 = this.sinput.var;
      beta = this.sinput.beta;
      a = s2*(1-exp(-2*beta*dt));

      this.sinput.SetVar(sqrt(a)); % set the variance of the white sequence
      W = this.GetWhiteSequence();

      r=zeros(1,n); % Gauss-Markov process
      for k=1:n;
        if (k==1)
          r(k) = normrnd(0,s2);
        else
          r(k) = exp(-beta*dt)*r(k-1) + W(k);
        endif
      end
      this.x = r;
    endfunction

    function [r] = GetWhiteSequence(this)
    % generates a Gaussian White sequence from N(0,s2).
      n = this.sinput.length;
      fcn = @(m,s,n) normrnd(m,s,[1,n]);

      s2 = this.sinput.var;
      r = fcn(0,s2,n); % white sequence N(0,s2)
      this.x = r;
    endfunction

    function [x] = GetWienerSequence(this)
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
      this.x = r;
    endfunction

    function [] = PlotBernoulli(this)
      r = this.GetBernoulli();
      figure;
      stem(r);
      title('Bernoulli Trials');
      this.x = r; % store for Stats method
    endfunction

    function [] = PlotRandomWalk(this)
      r = this.GetRandomWalk();
      figure;
      plot(r,'--.');
      title('Random Walk');
      this.x = r;
    endfunction

    function [] = PlotGaussMarkov(this)
      r = this.GetGaussMarkov();
      figure;
      plot(r,'.');
      title('Gauss-Markov');
      this.x = r;
    endfunction

    function [] = PlotWhiteSequence(this)
      r = this.GetWhiteSequence();
      figure;
      plot(r,'.');
      title('Gaussian White Sequence');
      this.x = r;
    endfunction

    function [] = PlotWienerSequence(this)
      r = this.GetWienerSequence();
      figure;
      plot(r,'.');
      title('Wiener Sequence');
      this.x = r;
    endfunction

  endmethods % Private
endclassdef
