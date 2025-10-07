classdef TimeSeries < handle
  % Time Series
  % [1]
  % [2]

  methods (Static = true) % Public

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

