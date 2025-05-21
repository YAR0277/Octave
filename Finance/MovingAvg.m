classdef MovingAvg < handle
  % Moving Averages
  % https://en.wikipedia.org/wiki/Moving_average#
  % https://en.wikipedia.org/wiki/Exponential_smoothing#

  methods (Static = true) % Public

    function [r] = SMA(x,wlen)
      % calculates the Simple Moving Average
      try
        r = movmean(x,wlen);
      catch ME
        fprintf('error: %s at file(%s), name(%s), line(%d), column(%d)\n',...
          ME.message,ME.stack(end).file,ME.stack(end).name,ME.stack(end).line,ME.stack(end).column);
        return;
      end_try_catch
    endfunction

    function [r] = WMA(x,w,wndLen)
      % calculates the weighted Moving Average
      % https://en.wikipedia.org/wiki/Moving_average#Weighted_moving_average
      n = size(x,2);
      wgtLen = size(w,2);
      if wgtLen~=wndLen
        fprintf('error: window length(%d) not equal to weighting vector length(%d). \n',wndLen,wgtLen);
        return;
      endif

      try
        r = zeros(1,n);
        iseven = mod(wndLen,2) == 0;
        for i=1:n
          if iseven
            lwhl = (wndLen/2)-1;  % left window half length
            rwhl = (wndLen)/2;    % right window half length
          else
            lwhl = (wndLen-1)/2;  % left window half length
            rwhl = (wndLen-1)/2;  % right window half length
          endif

          mix = lwhl + 1;         % middle index
          nlwi = min(i-1,lwhl);   % number of left window indices in lwhl, [0,lwhl]
          wix1 = mix - nlwi;      % window index start

          nrwi = min(n-i,rwhl);   % number of right window indices in rwhl, [0,rwhl]
          wix2 = mix + nrwi;      % window index end

          ix1=max(i-lwhl,1);      % data index start
          ix2=min(i+rwhl,n);      % data index end
          r(i) = (sum(x(ix1:ix2).*w(wix1:wix2)) / sum(w(wix1:wix2)));
        endfor
      catch ME
          fprintf('error: %s at file(%s), name(%s), line(%d), column(%d)\n',...
            ME.message,ME.stack(end).file,ME.stack(end).name,ME.stack(end).line,ME.stack(end).column);
          return;
      end_try_catch
    endfunction

    function [r] = MMA(x,wlen)
      % calculates the Modified Moving Average = EMA with alpha = 1/wlen
      alpha = 1/wlen;
      if wlen < 1
        fprintf('error: window length(%d) must be at least 1. \n',wlen);
        return;
      endif
      r = MovingAvg.EMA(x,alpha);
    endfunction

    function [r] = EMA(x,alpha)
      % calculates the Exponential Moving Average
      % https://en.wikipedia.org/wiki/Exponential_smoothing#
      n = size(x,2);
      if n < 1
        fprintf('error: input vector length(%d) must be at least 1. \n',n);
        return;
      endif

      try
        r = zeros(1,n);
        for i=1:n
          if i==1
            r(i) = x(i);
          else
            r(i) = alpha*x(i) + (1 - alpha)*r(i-1);
          endif
        endfor
      catch ME
          fprintf('error: %s at file(%s), name(%s), line(%d), column(%d)\n',...
            ME.message,ME.stack(end).file,ME.stack(end).name,ME.stack(end).line,ME.stack(end).column);
          return;
      end_try_catch
    endfunction

  endmethods
endclassdef
