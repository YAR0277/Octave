classdef Price < handle
  % class to handle prices of financial data

  properties
    InFile        % Reference to FidelityFile or YahooFile class
    timestamp     % t - timestamp of prices
    timestep      % time interval of price data {'day','week','month','quarter'}
    volume        % volume data
  endproperties

  methods % Public

    function obj = Price(inFile)
      % c'tor to create a Price object, input is an FidelityFile object.
      if ~isa(inFile, 'FidelityFile') && ~isa(inFile, 'YahooFile')
        error('Invalid input file class (%s)\n',class(inFile));
      endif

      pkg load image; % imregionalmax, imregionalmin
      obj.InFile = inFile;
      obj.timestamp = inFile.GetTimestamp; %obj.data.Date;
      obj.timestep = Util.GetTimeStep(obj.timestamp);
      obj.volume = inFile.GetVolume; %obj.data.Volume;
    endfunction

    function [lt0,gt0] = GetIQM(this,x)
      % returns IQM for negative (lt0) and positive (gt0) price changes
      dx = Util.Diff(x);
      id = dx < 0;
      iu = dx > 0;
      iz = dx == 0;
      lt0 = Util.IQM(dx(id));
      gt0 = Util.IQM(dx(iu));
    endfunction

    function [r] = GetPrices(this)
      r = this.InFile.Data.(this.InFile.DataCol);
    endfunction

    function [r] = Plot(this)
      figure;
      this.DoPlot();
      ## https://stackoverflow.com/questions/67171470/easy-waybuiltin-function-to-put-main-title-in-plot-in-octave
      S = axes('visible','off','title',this.InFile.Symbol,'FontSize',16);
    endfunction

    function [r] = Stats(this)
      % calculates statistics on prices
      price = this.GetPrices();
      if isempty(price)
        fprintf('No price data available.\n');
        return;
      endif

      fprintf('Symbol: %s\n',this.InFile.Symbol);
      t1 = this.timestamp(1);
      t2 = this.timestamp(end);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr.: %d\n',datestr(t1),datestr(t2),this.timestep,numel(price));
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
      [~,p] = Sutil.GetSignal(this.timestamp,price);
      fprintf('Price Interp: slope of linear interpolation %.2f \n',p(1));

      prExtrap = interp1(this.timestamp,price,datenum(date()),"extrap");
      fprintf('Price Extrap: (%s) %.2f \n',date(),prExtrap);

      vol = this.volume;
      fprintf('Volume: range: [%d,%d], last price (%d), percentile (%.2f%%)\n',min(vol),max(vol),vol(end),Util.CalcPercentile(vol,vol(end)));
    endfunction

    function [r] = WhatToBuy(varargin)
      % call is either 1) WhatToBuy() - no params, tol=std(x) or 2) WhatToBuy(10) - tol as parameter
      this = varargin{1}; % first param for a class method is 'this'
      x = this.GetPrices();
      [lt0,gt0] = this.GetIQM(x);
      switch nargin
        case 1
          tol = gt0 - lt0; % default case
        case 2
          tol = varargin{2}; % tol given as parameter
        otherwise
          error('invalid number of arguments %d. \n',nargin);
      endswitch

      idxMax = imregionalmax(x);
      idxMin = imregionalmin(x);
      [idxMin,idxMax] = this.FilterNoiseFromLocalMaxMin(idxMin,idxMax,x,tol);

      t=this.timestamp;

      figure;
      plot(t,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(this.timestamp);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      hold on;
      [vals,coeffs] = Util.GetSignal(t,x);
      plot(t,vals,'--','Color',Color.Brown);

      tmax = t(idxMax);
      xmax = x(idxMax);
      smax = Util.GetSignal(tmax(2:end),xmax(2:end));
      plot(tmax(2:end),smax,'--','Color',Color.Green,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      tmin = t(idxMin);
      xmin = x(idxMin);
      smin = Util.GetSignal(tmin(2:end),xmin(2:end));
      plot(tmin(2:end),smin,'--','Color',Color.Red,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      ylabel('Price','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;

      t1 = this.timestamp(1);
      t2 = this.timestamp(end);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr.: %d\n',datestr(t1),datestr(t2),this.timestep,numel(x));
      buyLineExtrap = interp1(tmin(2:end),smin,datenum(date()),"extrap");
      fprintf('Buy Line Extrap: (%s) %.2f \n',date(),buyLineExtrap);
      fprintf('Buy Price Range: [%.2f,%.2f]\n',buyLineExtrap+lt0,buyLineExtrap+gt0);
      fprintf('Price Last: (%.2f)\n',x(end));
      fprintf('Price Std. Dev: (%.2f), tol (%.2f)\n',std(x),tol);
      fprintf('IQM negatives: (%.2f), IQM positives (%.2f)\n',lt0,gt0);

      if this.GetBuyConditions(x,buyLineExtrap,gt0,coeffs)
        r = 1;
      else
        r = 0;
      endif
    endfunction

    function [r,buyLineExtrap] = WhatToBuyBatch(varargin)
      this = varargin{1}; % first param for a class method is 'this'
      x = this.GetPrices();
      [lt0,gt0] = this.GetIQM(x);
      switch nargin
        case 1
          tol = gt0 - lt0; % default case
        case 2
          tol = varargin{2}; % tol given as parameter
        otherwise
          error('invalid number of arguments %d. \n',nargin);
      endswitch

      idxMax = imregionalmax(x);
      idxMin = imregionalmin(x);
      [idxMin,idxMax] = this.FilterNoiseFromLocalMaxMin(idxMin,idxMax,x,tol);

      t=this.timestamp;

      [sx,coeffs] = Util.GetSignal(t,x);

      tmax = t(idxMax);
      xmax = x(idxMax);

      tmin = t(idxMin);
      xmin = x(idxMin);
      smin = Util.GetSignal(tmin,xmin);

      % if there is only 1 value in smin, i.e. prices have always increased,
      % then do the extrapolation using the price data and its signal (x & sx)
      % instead of the minimum price data and its signal (xmin & smin)
      if length(smin) < 2
        buyLineExtrap = interp1(t,sx,datenum(date()),"extrap");
      else
        buyLineExtrap = interp1(tmin,smin,datenum(date()),"extrap");
      endif


      if this.GetBuyConditions(x,buyLineExtrap,gt0,coeffs)
        r = 1;
      else
        r = 0;
      endif
    endfunction
  endmethods % Public

  methods (Access = private)

    function [] = AddStdDevLines(this,x)
      xlim = get(gca(),'xlim');
      n=xlim(2)-xlim(1)+1;
      dx=20;dy=0.5;

      m = mean(x);
      plot([xlim(1):xlim(2)],ones(1,n)*m,'--','color',[0,0.5,0]);%,'LineWidth',Constant.PlotLineWidth);
      text(xlim(1)+dx,m+0.5,sprintf('m=%.2f',m),'color',[0,0.5,0]);

      plot([xlim(1):xlim(2)],ones(1,n)*(m + std(x)),'--','color','red');%,'LineWidth',Constant.PlotLineWidth);
      text(xlim(1)+dx,(m + std(x))+dy,sprintf('m+1σ=%.2f',m+std(x)),'color','red');
      plot([xlim(1):xlim(2)],ones(1,n)*(m + 2*std(x)),'--','color','red');%,'LineWidth',Constant.PlotLineWidth);
      text(xlim(1)+dx,(m + 2*std(x))+dy,sprintf('m+2σ=%.2f',m+2*std(x)),'color','red');

      plot([xlim(1):xlim(2)],ones(1,n)*(m - std(x)),'--','color','red');%,'LineWidth',Constant.PlotLineWidth);
      text(xlim(1)+dx,(m - std(x))-dy,sprintf('m-1σ=%.2f',m-std(x)),'color','red');
      plot([xlim(1):xlim(2)],ones(1,n)*(m - 2*std(x)),'--','color','red');%,'LineWidth',Constant.PlotLineWidth);
      text(xlim(1)+dx,(m - 2*std(x))-dy,sprintf('m-2σ=%.2f',m-2*std(x)),'color','red');
    endfunction

    function [] = DoPlot(this)

      t=this.timestamp;
      price = this.GetPrices();

      subplot(2,1,1);
      plot(t(2:end),price(2:end),'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      s = Util.GetSignal(t,price);
      plot(t(2:end),s(2:end),'--','Color',Color.Red,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(this.timestamp);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('Price','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;

      subplot(2,1,2);
      dp = Util.Diff(price);
      plot(t(2:end),dp,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      this.AddStdDevLines(dp);

      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('Price Differences','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;
    endfunction

    function [idxMin,idxMax] = FilterNoiseFromLocalMaxMin(this,idxMin,idxMax,price,tol)
      % removes local maxes or mins when they are noise. A noisy extrema
      % is the second of two consecutive extrema when they differ by less than tol.
      lastMaxMin = struct('type','none','index',0,'price',0);
      currMaxMin = lastMaxMin;

      n = length(idxMin);
      for i=2:n
        if idxMax(i)==0 && idxMin(i)==0
          continue; % neither max nor min continue
        elseif idxMax(i)==1 && idxMin(i)==1
          error('data point at index %d cannot be both max and min',i);
        elseif idxMax(i)==0 && idxMin(i)==1 % local min
          currMaxMin.type = 'min'; currMaxMin.index = i; currMaxMin.price = price(i);
        elseif idxMax(i)==1 && idxMin(i)==0 % local max
          currMaxMin.type = 'max'; currMaxMin.index = i; currMaxMin.price = price(i);
        endif

        if lastMaxMin.index==0
          lastMaxMin = currMaxMin;
          continue;
        endif

        if strcmpi(lastMaxMin.type,'max')==1 && strcmpi(currMaxMin.type,'min')==1
          if abs(lastMaxMin.price-currMaxMin.price) <= tol
            idxMin(currMaxMin.index) = 0; % currMaxMin is noise, remove it from idxMins
          else
            lastMaxMin = currMaxMin;
          endif

        elseif strcmpi(lastMaxMin.type,'min')==1 && strcmpi(currMaxMin.type,'max')==1
          if abs(lastMaxMin.price-currMaxMin.price) <= tol
            idxMax(currMaxMin.index) = 0; % currMaxMin is noise, remove it from idxMaxs
          else
            lastMaxMin = currMaxMin;
          endif

        elseif strcmpi(lastMaxMin.type,'min')==1 && strcmpi(currMaxMin.type,'min')==1
          if currMaxMin.price <= lastMaxMin.price
            idxMin(lastMaxMin.index) = 0; % lastMaxMin is noise, remove it from idxMins
            lastMaxMin = currMaxMin;
          endif

        elseif strcmpi(lastMaxMin.type,'max')==1 && strcmpi(currMaxMin.type,'max')==1
          if currMaxMin.price >= lastMaxMin.price
            idxMax(lastMaxMin.index) = 0; % lastMaxMin is noise, remove it from idxMaxs
            lastMaxMin = currMaxMin;
          endif
        endif
      endfor
    endfunction

    function [tof] = GetBuyConditions(~,x,buyLineExtrap,gt0,coeffs)
      tof = x(end) < buyLineExtrap + gt0 ... % low price
        && coeffs(1) > 0; % prices rising
    endfunction
  endmethods % Private
endclassdef
