classdef Sutil < Util
  % utilities for Signals folder
  % https://www.gaussianwaves.com/2013/12/power-and-energy-of-a-signal/
  % https://www.mathworks.com/matlabcentral/answers/2018831-determining-signal-to-noise-ratio
  % https://stackoverflow.com/questions/63177236/how-to-calculate-signal-to-noise-ratio-using-python
  % http://nipy.org/nitime/examples/snr_example.html

  properties (Constant)
  endproperties

  methods (Static = true) % Public

    function [r2] = CoefficientOfDetermination(x,x_hat)
      % https://en.wikipedia.org/wiki/Coefficient_of_determination
      % goodness of fit is when this statistic is close to 1,
      % then UnexplainedVariation/TotalVariation is close to 0.
      r2 = 1 - ( sum((x - x_hat).^2) / sum((x - mean(x)).^2) ); % 1 - UnexplainedVariation/TotalVariation
    endfunction

    function [r] = UnexplainedVariation(x,x_hat)
      r = sum((x - x_hat).^2);
    endfunction

    function [r] = ExplainedVariation(x,x_hat)
      r = sum((x_hat - mean(x)).^2);
    endfunction

    function [r] = TotalVariation(x,x_hat)
      r = sum((x - mean(x)).^2);
    endfunction

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

    function [r,p] = GetTrendPoly(t,x,n)
      % https://octave.sourceforge.io/octave/function/polyfit.html
      [p,s] = polyfit(t,x,n);
      r = s.yf;
    endfunction

    function [x_hat,b_hat] = GetTrendLogistic(t,x,b0)
      % https://octave.sourceforge.io/optim/function/nlinfit.html
      model = @(b, t) (b(3) ./ (1 + b(2) * exp (- b(1) * t)));
      [b_hat, R, J, covb, mse] = nlinfit (t, x, model, b0);
      x_hat = model(b_hat,t);
    endfunction

    function [x_hat,b_hat] = GetTrendMitscherlich(t,x,b0)
      % https://octave.sourceforge.io/optim/function/nlinfit.html
      model = @(b, t) (b(1) + b(2) * exp (b(3) * t));
      [b_hat, R, J, covb, mse] = nlinfit (t, x, model, b0);
      x_hat = model(b_hat,t);
    endfunction

    function [x_hat,b_hat] = GetTrendGompertz(t,x,b0)
      % https://octave.sourceforge.io/optim/function/nlinfit.html
      model = @(b, t) exp (b(1) + b(2)*b(3).^t);
      [b_hat, R, J, covb, mse] = nlinfit (t, x, model, b0);
      x_hat = model(b_hat,t);
    endfunction

    function [x_hat,b_hat,R] = GetTrendAllometric(t,x,b0)
      % https://octave.sourceforge.io/optim/function/nlinfit.html
      model = @(b, t) (b(2)*t.^b(1));
      [b_hat, R, J, covb, mse] = nlinfit (t, x, model, b0);
      x_hat = model(b_hat,t);
    endfunction

    function [] = Plot(t,x)
      s = Sutil.GetSignal(t,x);
      n = Sutil.GetNoise(t,x);
      figure;
      hold on;
      plot(t,x,'--.','Color','k','MarkerSize',Constant.PlotMarkerSize);
      plot(t,s,'--.','Color','b','MarkerSize',Constant.PlotMarkerSize);
      plot(t,n,'--.','Color','r','MarkerSize',Constant.PlotMarkerSize);

      [xticks,fmt] = Util.GetDateTicks(t); %this.GetTimeTicks(t);
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

    function [r] = SNR(t,x)
      r = Sutil.GetSignalPower(t,x) / Sutil.GetNoisePower(t,x);
      r = 10*log10(r); % convert to dB
    endfunction

  endmethods
endclassdef
