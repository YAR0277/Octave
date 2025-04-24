classdef RandomSequence

  methods (Static = true)

    function [r] = GenerateGaussMarkov(dt,N)
      % generates Gauss-Markov sequence of length N, spacing dt.
      s2 = 1 % variance of Gauss-Markov process
      beta = 1   % time-constant of Gauss-Markov process
      a = s2*(1-exp(-2*beta*dt));
      W = RandomSequence.GenerateWhiteSequence(sqrt(a),N);
      r=zeros(1,N); % Gauss-Markov process
      for k=1:N;
        if (k==1)
          r(k) = normrnd(0,s2);
        else
          r(k) = exp(-beta*dt)*r(k-1) + W(k);
        endif
      end
    endfunction

    function [r] = GenerateWhiteSequence(sigma,N)
    % generates White sequence, length N from N(0,sigma).
      fcn = @(m,s,n) normrnd(m,s,[1,N]);
      r = fcn(0,sigma,N); % white sequence N(0,...)
    endfunction

    function [x] = GenerateWienerSequence(sigma,N)
      % generates Wiener sequence of length N.
      r=zeros(1,N);
      w=normrnd(0,sigma,[1,N]);
      for i=1:N
        if (i==1)
          x(i)=0; % Wiener sequence, x(0)=0.
        else
          x(i) = x(i-1) + w(i);
        endif
      endfor
    endfunction

  endmethods
endclassdef
