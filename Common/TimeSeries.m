classdef TimeSeries < handle
  % Time Series
  % [1]
  % [2]

  methods (Static = true) % Public

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

    function [] = PlotTrend(file,wlen)
      % [] = PlotTrend(wlen) where window length, wlen=30, for example.
      if ~isa(file,'CsvFile') && ~isa(file,'Returns') && ~isa(file,'RSI') && ~isa(file,'StoOsc')
        return;
      endif

      hold on;
      ax = gca;
      t = file.GetTimestamp;
      x = file.GetValue;
      trend = MovingAvg.SMA(x,wlen);
      plot(ax,t,trend,'--','Color',Color.Maroon,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      hold off;
    endfunction
  endmethods
endclassdef

