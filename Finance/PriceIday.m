classdef PriceIday < PriceEx
  % class to handle intraday prices of financial data, used as composition ("has-a") in IntradayFile

  methods % Public

    function obj = PriceIday(inFile)
      obj = obj@PriceEx(inFile);
    endfunction

    function [r] = Plot(this)
      figure;
      this.DoPlot();
      ## https://stackoverflow.com/questions/67171470/easy-waybuiltin-function-to-put-main-title-in-plot-in-octave
    endfunction

    function [r] = Stats(this)
      % calculates statistics on prices
      price = this.GetPrices();
      if isempty(price)
        fprintf('No price data available.\n');
        return;
      endif

      fprintf('Symbol: %s\n',this.InFile.Symbol);
      timestamp = this.GetTimestamp();
      t1 = timestamp(1);
      t2 = timestamp(end);
      timestep = Util.GetTimeStep(timestamp);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr.: %d\n',datestr(t1),datestr(t2),timestep,numel(price));
      fprintf('Price: range: [%.2f,%.2f], mean (%.2f), stdev (%.2f)\n',min(price),max(price),mean(price),std(price));
      fprintf('Price: last: %.2f, δP: %.2f\n',price(end),price(end)-price(end-1));
      fprintf('Price: last: max.-last (below ceiling): %.2f\n',max(price)-price(end));
      fprintf('Price: last: last-min. (above floor): %.2f\n',price(end)-min(price));

      dp = Util.Diff(price);
      fprintf('Price differences: range: [%.2f,%.2f], mean (%.2f), stdev (%.2f), µ-1σ (%.2f), last+(µ-1σ): %.2f\n',min(dp),max(dp),mean(dp),std(dp),mean(dp)-std(dp),price(end)+(mean(dp)-std(dp)));
      n = numel(dp);
      n1 = sum(dp > mean(dp) + std(dp) | dp < mean(dp) - std(dp));
      n2 = sum(dp > mean(dp) + 2*std(dp) | dp < mean(dp) - 2*std(dp));
      fprintf('Price differences: g.t. 1 stdev (num=%d, pct=%.2f%%), g.t. 2 stdev (num=%d, pct=%.2f%%)\n',n1,100*(n1/n),n2,100*(n2/n));
      id = dp < 0;
      iu = dp > 0;
      iz = dp == 0;
      fprintf('Price differences < 0: Nr. (%d), mean (%.2f), IQM (%.2f), range: [%.2f,%.2f], last+IQM: %.2f \n',sum(id),mean(dp(id)),Util.IQM(dp(id)),min(dp(id)),max(dp(id)),price(end)+Util.IQM(dp(id)));
      fprintf('Price differences > 0: Nr. (%d), mean (%.2f), IQM (%.2f), range: [%.2f,%.2f], last+IQM: %.2f \n',sum(iu),mean(dp(iu)),Util.IQM(dp(iu)),min(dp(iu)),max(dp(iu)),price(end)+Util.IQM(dp(iu)));
      fprintf('Price differences = 0: Nr. (%d) \n',sum(iz));

      addpath(genpath('..'));
      [~,p] = Sutil.GetSignal(timestamp,price);
      fprintf('Price Interp: slope of linear interpolation %.2f \n',p(1));

      prExtrap = interp1(timestamp,price,datenum(date()),"extrap");
      fprintf('Price Extrap: (%s) %.2f \n',date(),prExtrap);

      vol = this.InFile.GetVolume;
      fprintf('Volume: range: [%d,%d], last price (%d), percentile (%.2f%%)\n',min(vol),max(vol),vol(end),Util.CalcPercentile(vol,vol(end)));
    endfunction

    function [r] = PlotMM(varargin)
      % call is either 1) PlotMM() - no params, tol=std(x) or 2) PlotMM(10) - tol as parameter
      this = varargin{1}; % first param for a class method is 'this'
      [t,x] = this.GetPriceData(1e4); % 10000, a big number, returns all availabe data
      [lt0,gt0] = this.GetIQM(x);
      switch nargin
        case 1
          % the first parameter is the 'this', the PriceEx object
        case 2
          tol = gt0 - lt0; % default case, no tolerance parameter given
        case 3
          tol = varargin{2}; % tol given as parameter
        otherwise
          error('invalid number of arguments %d. \n',nargin);
      endswitch

      idxMax = imregionalmax(x);
      idxMin = imregionalmin(x);
      [idxMin,idxMax] = this.FilterNoiseFromLocalMaxMin(idxMin,idxMax,x,tol);

      figure;
      plot(t,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      Util.AddWatermark(gca,this.InFile.Ticker);

      timestamp = this.GetTimestamp();
      [xticks,fmt] = Util.GetDateTicks(timestamp);
      set(gca,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      hold on;
      [t1,x1] = this.GetPriceData(5); % trend based on last 5
      [sx,coeffs] = Util.GetSignal(t1,x1);
      plot(t1,sx,'--','Color',Color.Brown);

      tmax = t(idxMax);
      xmax = x(idxMax);
      smax = Util.GetSignal(tmax,xmax);
      plot(tmax,smax,'--','Color',Color.Green,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      tmin = t(idxMin);
      xmin = x(idxMin);
      smin = Util.GetSignal(tmin,xmin);
      plot(tmin,smin,'--','Color',Color.Red,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      ylabel('Price','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;

      timestep = Util.GetTimeStep(timestamp);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr.: %d\n',datestr(timestamp(1)),datestr(timestamp(end)),timestep,numel(x));
      if length(smin) < 2
        buyLineExtrap = interp1(t1,sx,datenum(date()),"extrap");
      else
        buyLineExtrap = interp1(tmin,smin,datenum(date()),"extrap");
      endif
      fprintf('Buy Line Extrap: (%s) %.2f \n',date(),buyLineExtrap);
      fprintf('Buy Price Range: [%.2f,%.2f]\n',buyLineExtrap+lt0,buyLineExtrap+gt0);
      fprintf('Price Last: (%.2f)\n',x(end));
      fprintf('Price Std. Dev: (%.2f), tol (%.2f)\n',std(x),tol);
      fprintf('IQM negatives: (%.2f), IQM positives (%.2f)\n',lt0,gt0);

      if this.GetBuyConditions(x,buyLineExtrap,gt0)
        r = 1;
      else
        r = 0;
      endif
    endfunction

    function PlotEMA(this,t,x)

      figure;
      tod = (t-floor(t))*86400; % time of day is seconds since midnight
      plot(tod,x,'--.','color',Color.LightGrey,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      Util.AddWatermark(gca,this.InFile.Ticker);

      xt = get(gca, 'xtick');
      labels = arrayfun(@(x) sprintf('%02d:%02d', ...
                      floor(x/3600),floor(mod(x,3600)/60)), ...
                      xt, 'UniformOutput', false);
      set(gca,'xticklabel',labels);
      xlim([xt(1) xt(end)]);

      hold on;
      cfg = Config.Instance();
      y = MovingAvg.EMA(x,cfg.get('EMAWindowLength'),cfg.get('EMAAlpha'));
      plot(tod,y,'-','color',Color.Orange,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidthThick);

      ylabel('EMA','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;
    endfunction

    function PlotSMA(this,t,x)

      figure;
      tod = (t-floor(t))*86400; % time of day is seconds since midnight
      plot(tod,x,'--.','color',Color.LightGrey,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      Util.AddWatermark(gca,this.InFile.Ticker);

      xt = get(gca, 'xtick');
      labels = arrayfun(@(x) sprintf('%02d:%02d', ...
                      floor(x/3600),floor(mod(x,3600)/60)), ...
                      xt, 'UniformOutput', false);
      set(gca,'xticklabel',labels);
      xlim([xt(1) xt(end)]);

      hold on;
      cfg = Config.Instance();
      y = MovingAvg.SMA(x,cfg.get('SMAWindowLength'));
      plot(tod,y,'-','color',Color.Orange,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidthThick);

      ylabel('SMA','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;
    endfunction
  endmethods % Public
endclassdef
