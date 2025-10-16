classdef TimeSeries < handle
  % Time Series
  % [1] A First Course on Time Series Analysis, Examples with SAS (2006)
  % [2] Introductory Time Series with R

  properties
    Error
    Seasonal
    Trend
    timestamp
    value
  endproperties

  methods % Public

    function [obj] = TimeSeries(file) % c'tor
      if ~isa(file,'CsvFile') && ~isa(file,'Returns') && ~isa(file,'RSI') && ~isa(file,'StoOsc')
        return;
      endif

      obj.timestamp = obj.MakeColumnVector(file.GetTimestamp);
      obj.value = obj.MakeColumnVector(file.GetValue);
    endfunction

    function [r] = get.Error(this)
      r = this.Error;
    endfunction

    function [r] = get.Seasonal(this)
      r = this.Seasonal;
    endfunction

    function [r] = get.Trend(this)
      r = this.Trend;
    endfunction

    function [r] = acf(this,k,x)
      % [r(k)] = acf(k,x) autocorrelation function at k (lag) for sequence x.
      r = this.acvf(k,x)/this.acvf(1,x);
    endfunction

    function [r] = acvf(this,k,x)
      % [r(k)] = acvf(k,x) autocovariance function at k (lag) for sequence x.
      acv = this.acvImpl(x);
      if k > 0 && k <= length(acv)
        r = acv(k);
      endif
    endfunction

    function [acv] = acvImpl(~,x)
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

    function [t,m,s,z] = Decompose(this,wndLen)
      % Additive decomposition of time series: x = m + s + z, where m-trend, s-seasonal, z-error.
      % [t,m,s,z] = Decompose(wndLen) where window length, wndLen=12, for example.
      x = this.value;
      [t,m] = this.CalcTrend(x,wndLen);
      [t,s] = this.CalcSeasonal(x,wndLen);
      [t,z] = this.CalcError(x,wndLen);
    endfunction

    function [] = Plot(this,wndLen)
      % Plots time series
      % [] = Plot(wndLen) where window length, wndLen=12, for example.
      figure;
      hold on;
      ax = gca;
      plot(ax,this.timestamp,this.value,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.DoXTick(ax);
      title('Time Series','FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction

    function [] = PlotAdjusted(this,wndLen)
      % Plots seasonally adjusted time series
      % [] = PlotAdjusted(wndLen) where window length, wndLen=12, for example.
      figure;
      hold on;
      ax = gca;
      [t,m,~,z] = this.Decompose(wndLen);
      plot(ax,t,m+z,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.DoXTick(ax);
      title('Seasonally Adjusted Time Series','FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction

    function [] = PlotAggregate(this,dt)
      % [] = PlotAggregate(dt) where dt=12, for example.
      figure;
      hold on;
      ax = gca;
      [t,x] = Util.Aggregate(this.timestamp,this.value,dt);
      plot(ax,t,x,'--','Color',Color.Maroon,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.DoXTick(ax);
      grid on;
      hold off;
    endfunction

    function [] = PlotCorrelogram(this,x)
      % [] = PlotCorrelogram(x) where x is random sequence. The random sequence is assumed
      % to be trend adjusted, see [1], p.36.
      figure;
      hold on;
      ax = gca;
      r = this.acvImpl(x)/this.acvf(1,x);
      plot(ax,[0:length(r)-1],r,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      ylabel('ACF');
      xlabel('lag');
      grid on;
      grid minor;
      hold off;
    endfunction

    function [] = PlotDecompose(this,wndLen)
      % Plots error component of time series
      % [] = PlotDecompose(wndLen) where window length, wndLen=12, for example.
      [t,m,s,z] = this.Decompose(wndLen);

      figure;
      subplot(4,1,1);
      plot(t,m+s+z,'--.',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      ax = gca;
      this.DoXTick(ax);
      ylabel('Observation','FontSize',Constant.YLabelFontSize);
      grid on;
      grid minor;

      subplot(4,1,2);
      plot(t,m,'--.',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      ax = gca;
      this.DoXTick(ax);
      ylabel('Trend','FontSize',Constant.YLabelFontSize);
      grid on;
      grid minor;

      subplot(4,1,3);
      plot(t,s,'--.',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      ax = gca;
      this.DoXTick(ax);
      ylabel('Seasonal','FontSize',Constant.YLabelFontSize);
      grid on;
      grid minor;

      subplot(4,1,4);
      plot(t,z,'--.',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      ax = gca;
      this.DoXTick(ax);
      ylabel('Error','FontSize',Constant.YLabelFontSize);
      grid on;
      grid minor;

      S = axes('visible','off','title','Additive Decomposition of Time Series','FontSize',16);
    endfunction

    function [] = PlotError(this,wndLen)
      % Plots error component of time series
      % [] = PlotError(wndLen) where window length, wndLen=12, for example.
      figure;
      hold on;
      ax = gca;
      [t,~,~,z] = this.Decompose(wndLen);
      plot(ax,t,z,'--.',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.DoXTick(ax);
      title('Error Component of Time Series','FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction

    function [] = PlotSeasonal(this,wndLen)
      % Plots seasonal component of time series
      % [] = PlotSeasonal(wndLen) where window length, wndLen=12, for example.
      figure;
      hold on;
      ax = gca;
      [t,~,s,~] = this.Decompose(wndLen);
      plot(ax,t,s,'--.',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.DoXTick(ax);
      title('Seasonal Component of Time Series','FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction

    function [] = PlotTrend(this,wndLen)
      % Plots trend of time series
      % [] = PlotTrend(wndLen) where window length, wndLen=12, for example.
      figure;
      hold on;
      ax = gca;
      [t,m,~,~] = this.Decompose(wndLen);
      plot(ax,t,m,'--.',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.DoXTick(ax);
      title('Trend of Time Series','FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction
  endmethods

  methods (Access = private)

    function [t,z] = CalcError(this,x,wndLen)
      % Removes trend and seasonal components from series
      % [] = CalcError(wndLen) where window length, wndLen=12, for example.
      [t,m] = this.CalcTrend(x,wndLen); % trend
      x = x - m;
      [t,s] = this.CalcSeasonal(x,wndLen); % seasonal
      x = x - s;
      t = this.timestamp;
      z = x; % additive seasonal and trend
      this.Error = z;
    endfunction

    function [t,s] = CalcSeasonal(this,x,wndLen)
      % Removes trend from series
      % [] = CalcSeasonal(wndLen) where window length, wndLen=12, for example.
      m = MovingAvg.CMA(x,wndLen); % trend
      m = this.MakeColumnVector(m);
      t = this.timestamp;
      s = x - m; % additive seasonal effect
      this.Seasonal = s;
    endfunction

    function [t,m] = CalcTrend(this,x,wndLen)
      % Calculates series trend using Centered Moving Average.
      % [t,m] = CalcTrend(t,x,wndLen) where window length, wndLen=12, for example.
      m = MovingAvg.CMA(x,wndLen); % trend
      m = this.MakeColumnVector(m);
      t = this.timestamp;
      this.Trend = m;
    endfunction

    function [] = DoXTick(this,ax)
      [xticks,fmt] = Util.GetDateTicks(this.timestamp);
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim(ax,[this.timestamp(1) this.timestamp(end)]);
    endfunction

    function [x] = MakeColumnVector(~,x)
      % make x into column vector
      if isrow(x)
        x = transpose(x);
      endif
    endfunction
  endmethods
endclassdef

