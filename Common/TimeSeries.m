classdef TimeSeries < handle
  % Time Series
  % [1]
  % [2]

  methods (Static = true) % Public

    function [r] = acf(k,x)
      % [r(k)] = acf(k,x) autocorrelation function at k (lag) for sequence x.
      r = TimeSeries.acvf(k,x)/TimeSeries.acvf(1,x);
    endfunction

    function [r] = acvf(k,x)
      % [r(k)] = acvf(k,x) autocovariance function at k (lag) for sequence x.
      acv = TimeSeries.acvImpl(x);
      if k > 0 && k <= length(acv)
        r = acv(k);
      endif
    endfunction

    function [acv] = acvImpl(x)
      % [acv] = acvImpl(x) autocovariance function of sequence x.
      n = length(x);
      xbar = mean(x);
      acv = NaN(n,1);
      for k=0:n-1 % lag variable
        s = 0;
        for t=1:n-k
          s = s + (x(t) - xbar)*(x(t+k) - xbar);
        endfor
        acv(k+1) = s/n; % lag 0 is at acv(1), lag 1 is at acv(2), ...
      endfor
    endfunction

    function [t,x] = CalcSeasonal(file,wndLen)
      % [t,x] = CalcSeasonal(wndLen) where window length, wndLen=12, for example.
      if ~isa(file,'CsvFile') && ~isa(file,'Returns') && ~isa(file,'RSI') && ~isa(file,'StoOsc')
        return;
      endif

      t = file.GetTimestamp;
      x = file.GetValue;
      m = MovingAvg.CMA(x,wndLen); % trend

      if isrow(x) % x - column vector
        x = transpose(x);
      endif
      if isrow(m) % m - column vector
        m = transpose(m);
      endif
      s = x - m; % additive seasonal effect

      x = x - s; % seasonally adjusted series = x - seasonal effect
    endfunction

    function [] = PlotAggregate(file,dt)
      % [] = PlotAggregate(dt) where dt=12, for example.
      if ~isa(file,'CsvFile') && ~isa(file,'Returns') && ~isa(file,'RSI') && ~isa(file,'StoOsc')
        return;
      endif

      hold on;
      ax = gca;
      [t,x] = Util.Aggregate(file.GetTimestamp,file.GetValue,dt);
      plot(ax,t,x,'--','Color',Color.Maroon,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      hold off;
    endfunction

    function [] = PlotSeasonal(file,wndLen)
      % [] = PlotSeasonal(wndLen) where window length, wndLen=12, for example.
      if ~isa(file,'CsvFile') && ~isa(file,'Returns') && ~isa(file,'RSI') && ~isa(file,'StoOsc')
        return;
      endif

      hold on;
      ax = gca;
      [t,x] = TimeSeries.CalcSeasonal(file,wndLen); % seasonally adjusted series
      plot(ax,t,x,'--','Color',Color.Maroon,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      hold off;
    endfunction

    function [] = PlotTrend(file,wndLen)
      % [] = PlotTrend(wndLen) where window length, wndLen=30, for example.
      if ~isa(file,'CsvFile') && ~isa(file,'Returns') && ~isa(file,'RSI') && ~isa(file,'StoOsc')
        return;
      endif

      hold on;
      ax = gca;
      t = file.GetTimestamp;
      x = file.GetValue;
      trend = MovingAvg.SMA(x,wndLen);
      plot(ax,t,trend,'--','Color',Color.Maroon,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      hold off;
    endfunction
  endmethods
endclassdef

