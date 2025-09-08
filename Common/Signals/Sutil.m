classdef Sutil < handle
  % utilities for Signals folder
  % https://www.gaussianwaves.com/2013/12/power-and-energy-of-a-signal/
  % https://www.mathworks.com/matlabcentral/answers/2018831-determining-signal-to-noise-ratio
  % https://stackoverflow.com/questions/63177236/how-to-calculate-signal-to-noise-ratio-using-python
  % http://nipy.org/nitime/examples/snr_example.html

  properties (Constant)
  endproperties

  methods (Static = true) % Public

    function [p,e_var,r,p_var,fit_var] = DoLinearRegression(x,y)
      % https://octave.sourceforge.io/optim/function/LinearRegression.html
      pkg load optim;
    endfunction

    function [r] = GetNoise(t,x)
      s = Sutil.GetSignal(t,x);
      r = abs(x-s);
    endfunction

    function [r] = GetNoisePower(t,x)
      n = Sutil.GetNoise(t,x);
##      r = Sutil.Power(n);
      % define the noise power via standard deviation
      r = std(n);
    endfunction

    function [r,p] = GetSignal(t,x)
      % p(x) coefficients of a polynomial of degree n that minimizes the least-squares-error of the fit to the points [x(:),y(:)]
      % s is a structure containing: 'yf' - the values of the polynomial for each value of x. etc.
      [p,s] = polyfit(t,x,1);
      r = s.yf;
    endfunction

    function [r] = GetSignalPower(t,x)
      s = Sutil.GetSignal(t,x);
      r = Sutil.Power(s);
    endfunction

    function [r] = GetResidual(t,x)
      s = Sutil.GetSignal(t,x);
      r = abs(x-s);
    endfunction

    function [] = Plot(t,x)
      s = Sutil.GetSignal(t,x);
      n = Sutil.GetNoise(t,x);
      figure;
      hold on;
      plot(t,x,'--.','Color','k','MarkerSize',Futil.PlotMarkerSize);
      plot(t,s,'--.','Color','b','MarkerSize',Futil.PlotMarkerSize);
      plot(t,n,'--.','Color','r','MarkerSize',Futil.PlotMarkerSize);

      [xticks,fmt] = Futil.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      legend('price','signal','noise');
      grid on;
      grid minor;
      hold off;
    endfunction

    function [r] = Power(x)
      r = mean(x.*x);
    endfunction

    function [r] = RMS(x)
    % https://en.wikipedia.org/wiki/Root_mean_square
      r = sqrt(Sutil.Power(x));
    endfunction

    function [r] = Round(r)
      r = round(r.*100)./100; % round to nearest 2 decimal places
    endfunction

    function [r] = SNR(t,x)
      r = Sutil.GetSignalPower(t,x) / Sutil.GetNoisePower(t,x);
      r = 10*log10(r); % convert to dB
    endfunction

  endmethods
endclassdef
