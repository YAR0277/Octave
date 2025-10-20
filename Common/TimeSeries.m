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

    function [r] = ccf(this,k,x,y)
      % [r(k)] = acf(k,x) autocorrelation function at k (lag) for sequence x.
      r = this.ccvf(k,x,y)/this.ccvf(1,x,y);
    endfunction

    function [r] = ccvf(this,k,x,y)
      % [r(k)] = ccvf(k,x) cross covariance function at k (lag) for sequences x,y.
      ccv = this.ccvImpl(x,y);
      if k > 0 && k <= length(ccv)
        r = ccv(k);
      endif
    endfunction

    function [ccv] = ccvImpl(~,x,y)
      % [ccv] = ccvImpl(x) cross covariance function of sequences x,y.
      n = length(x);
      xbar = mean(x);
      ybar = mean(y);
      ccv = NaN(n,1);
      for k=0:n-1 % lag variable
        s = 0;
        for t=1:n-k
          s = s + (x(t+k) - xbar)*(y(t) - ybar);
        endfor
        ccv(k+1) = s/n; % lag 0 is at ccv(1), lag 1 is at ccv(2), ...
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

    function [] = PlotCorrelogram(this,x,y)
      % [] = PlotCorrelogram(x) or PlotCorrelogram(x,y), where x (and y) = random sequence(s).
      % The random sequences are assumed to be trend adjusted, see [1], p.36.

      if nargin == 2
        r = this.acvImpl(x)/this.acvf(1,x);
      elseif nargin == 3
        r = this.ccvImpl(x,y)/this.ccvf(1,x,y);
      else
        fmt = ['call: PlotCorrelogram(x,y) where x (and y) = random sequence(s).','\n'];
        fprintf(fmt);
        return;
      endif

      figure;
      ax = gca;
      plot(ax,[0:length(r)-1],r,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      hold on;
      % [2], p.36, mean = -1/n, variance = 1/n, stdev = 1/sqrt(n), draw lines at mean +/- 2 stds, i.e.
      % -1/n + 2/sqrt(n) and -1/n - 2/sqrt(n)
      mu = -1/length(x); % mean
      sig = sqrt(1/length(x)); % stdev
      this.AddDashedLine(ax,mu+2*sig);
      this.AddDashedLine(ax,mu-2*sig);
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

    function [] = Stats(this,x)
      % calculates statistics
      timestep = Util.GetTimeStep(this.timestamp);
      d1 = datestr(this.timestamp(1));
      d2 = datestr(this.timestamp(end));
      n = length(x);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr. Samples: %d\n',d1,d2,timestep,n);
      [v_max,i_max] = max(x);
      [v_min,i_min] = min(x);
      fprintf('Range: [%.2f,%.2f], Mean %.2f, Stdev %.2f\n',v_min,v_max,mean(x),std(x));
      fprintf('Min: %s, %.2f\n',datestr(this.timestamp(i_min),'mmm yyyy'),v_min);
      fprintf('Max: %s, %.2f\n',datestr(this.timestamp(i_max),'mmm yyyy'),v_max);
    endfunction
  endmethods

  methods (Access = private)

    function [] = AddDashedLine(this,ax,yval)
      limits = xlim(ax);
      n = limits(2);
      plot(ax,[0:n-1],yval*ones(n,1),'--','color',Color.Brown);
    endfunction

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

