% References
% [1] Intro to Random Signals, Brown & Hwang
% [2] Digital Signal Processing, Steven W. Smith
classdef DSP

  methods (Static = true)

    function [r] = CalcAutoCorrelationFcn(X,lags,N)
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

    function [r] = DFT(x,N)
      % calculates Discret Fourier Transform of a sequence, [1] p. 114.
      % x - the time domain sequence
      % N - number of samples in the sequence
      r=zeros(N,1);
      for k=1:N % k - the frequency index
        for n=1:N % n - time domain index
          r(k) = r(k) + x(n)*exp(-i*(2*pi*(n-1)*(k-1))/N); % (2.17.6)
        endfor
        r(k) = (1/N)*r(k); % normalization factor
      endfor
    endfunction

    function [f,P] = Periodogram(x,N,biFlag)
      % calculates the periodogram for a random sequence over [0,T], [1], p. 109.
      % x - the random sequence
      % N - the number of samples
      % biFlag - built-in flag (1-use built-in fcn)
      f = zeros(N/2+1,1); % frequency values
      P = zeros(N/2+1,1); % periodogram values
      if biFlag==1
        X = (1/N)*fft(x,N);
        else
        X = DSP.DFT(x,N);
      endif
      X = X(1:N/2+1); % unscaled periodogram, need only first N/2+1 of FT
      P = (4/N)*(abs(X).^2); % scaled periodogram, 4 is scale factor
      f = transpose((0:N/2)/N);
    endfunction

    function [rex,imx] = RealDFT(x,Nt)
      % calculates Discret Fourier Transform of a sequence, [1] p. 114.
      % x - the time domain sequence
      % Nt - number of samples in the sequence
      rex=[];imx=[];

      % Nt must be even
      if mod(Nt,2) ~= 0
        return;
      endif

      % Nf number of samples in frequency domain
      Nf = (Nt/2)+1;

      rex=zeros(Nf,1);
      imx=zeros(Nf,1);
      for k=1:Nf % k - the frequency index
        for n=1:Nt % n - time domain index
          rex(k) = rex(k) + x(n)*cos((2*pi*(n-1)*(k-1))/Nt); % (2.17.6)
          imx(k) = imx(k) + x(n)*sin((2*pi*(n-1)*(k-1))/Nt); % (2.17.6)
        endfor
        rex(k) = (2/Nt)*rex(k); % normalization factor
        imx(k) = (-2/Nt)*imx(k); % normalization factor
      endfor
    endfunction

    function [] = TestDFT(X,N)
      y1 = (1/N)*fft(X,N)';
      y2 = DSP.DFT(X,N);
      dy = abs(y1)-abs(y2); % difference
      fprintf('<INFO> The max difference is %.2f\n',max(dy));
      fprintf('<INFO> The mean difference is %.2f\n',mean(dy));
      fprintf('<INFO> The sum difference is %.2f\n',sum(dy));
    endfunction
  endmethods
endclassdef
