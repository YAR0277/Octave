classdef AutoCorrelationSequence

  properties
    gmVariance = 1 % variance of Gauss-Markov process
    gmBeta = 1   % time-constant of Gauss-Markov process
  endproperties

  methods

    function [r] = CalcAutoCorrelationFcn(~,X,lags,N)
      % approximates the auto correlation function for a random sequence,
      % according to the formula (2.15.2), p. 107, V(tau) =~ R(tau).
      % X - the random sequence
      % lags - the "tau" variable
      % N - the number of elements in the sequence. Time is T = N*dt.
      r=zeros(numel(lags),1);
      dlags=diff(lags);
      dt=dlags(1);
      for i=1:numel(lags)
        count=0; % keep track of how many in the sum
        k=1; % the time index
        ixOffset=uint32(lags(i)/dt); % the tau index
        while true
          if (k+ixOffset) <= N
            r(i) = r(i) + X(k)*X(k+ixOffset);
            count=count+1;
            k=k+1; % advance time
          else
            break;
          endif
        endwhile
        r(i) = (r(i) /(count)); % compute the average
      endfor
    endfunction

    function [r] = GenerateGaussMarkov(this,dt,N)
      % generates Gauss-Markov sequence of length N, spacing dt.
      a = this.gmVariance*(1-exp(-2*this.gmBeta*dt));
      W = this.GenerateWhiteSequence(0,sqrt(a),N);
      r=zeros(1,N); % Gauss-Markov process
      for k=1:N;
        if (k==1)
          r(k) = normrnd(0,this.gmVariance);
        else
          r(k) = exp(-this.gmBeta*dt)*r(k-1) + W(k);
        endif
      end
    endfunction

    function [r] = GenerateWhiteSequence(~,mu,sigma,n)
    % generates White sequence of length n from N(mu,sigma).
      fcn = @(m,s,n) normrnd(m,s,[1,n]);
      r = fcn(mu,sigma,n); % white sequence N(0,...)
    endfunction

  endmethods
endclassdef
