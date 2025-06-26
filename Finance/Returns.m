classdef Returns < handle
  % class to compute rate of returns of financial data

  properties
    data          % struct of input data
    finput        % Reference to Finput class
    returns       % rate of return
    timestamp     % t - timestamp of prices
    timestep      % time interval of price data {'day','week','month','quarter'}
    flgStemPlot   % stem plot flag: 1='stem' plot (default), otherwise 'bar' plot
    flgPctChange  % pctChange flag: 1=use pctChange (default), otherwise calc rate of return
    volume        % volume data
  endproperties

  properties (Access=private)
    A           % days, weeks, months or quarters in a year matrix
  endproperties

  methods % Public

    function obj = Returns(finput)
      % c'tor to create a Returns object, input is an Finput object.
      if ~isa(finput, 'Finput')
        return;
      endif

      obj.finput = finput;
      obj.data = readf(finput);
      obj.timestamp = obj.data.Date;
      obj.timestep = Futil.GetTimeStep(obj.timestamp);
      obj.flgPctChange = 1;
      obj.flgStemPlot = 0;
      obj.volume = obj.data.Volume;
    endfunction

    function [] = Calc(this)
      % calculates rate of returns

      price = this.data.(this.finput.dataCol);
      if numel(price) < 2 % at least 2 to get a return
        return;
      endif

      dp = diff(price);
      this.returns = Futil.Round(( dp./ price(1:end-1) )*100); % as a percent, rounded to 2 decimal places

    endfunction

    function [] = PlotBar(this)
      % plot returns as bar plot

      [t,y] = this.GetReturnData();
      if isempty(t) || isempty(y)
        fprintf('No return data found to plot.\n');
        return;
      endif

      figure;
      bar(t,y);

      [xticks,fmt] = Futil.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      ylabel('Rate of Return (%)','FontSize',16);
      title(this.finput.symbol,'FontSize',16);
      grid on;
    endfunction

    function [] = PlotStem(this)
      % plots returns as stem plot

      [t,y] = this.GetReturnData();
      if isempty(t) || isempty(y)
        fprintf('No return data found to plot.\n');
        return;
      endif

      figure;
      stem(t,y);

      [xticks,fmt] = Futil.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      ylabel('Rate of Return (%)','FontSize',16);
      title(this.finput.symbol,'FontSize',16);
      grid on;
      grid minor;
    endfunction

    function [r] = Plot(this)
      % calculates statistics on returns
      if this.flgStemPlot
        this.PlotStem();
      else
        this.PlotBar();
      endif
    endfunction

    function [r] = Stats(this)
      % calculates statistics on returns
      if this.flgPctChange
        this.DoStats(this.timestamp(1),this.timestamp(end),this.data.pctChange);
      else
        this.DoStats(this.timestamp(1),this.timestamp(end),this.returns);
      endif
    endfunction

  endmethods % Public

  methods (Access = private)

  function [] = DoLabels(this,dt,dx)
      t = [this.returns.firstDay];
      x = [this.returns.rateOfReturn];

      labels = num2str(x(:));

      t = arrayfun(@(t) t+dt, t(:)); % adjust t position

      ix = x > 0;
      x(ix) = arrayfun(@(x) x+dx, x(ix)); % adjust x position for pos returns
      ix = x <= 0;
      x(ix) = arrayfun(@(x) x-dx, x(ix)); % adjust x position for neg returns

      text(t,x,labels,'FontWeight','bold','FontSize',9);

    endfunction

    function [] = DoVolatility(this)

      y = [this.returns.rateOfReturn];
      vol = std(y); % standard deviation = volatility
      num = numel(y);
      tvals=arrayfun(@(s) Futil.GetDateNum(s),[this.returns(:).year]);

      hold on;
      plot(tvals,(0+vol)*ones(num,1),'r--');
      plot(tvals,(0-vol)*ones(num,1),'r--');
      hold off;
    endfunction

    function [r] = DoStats(this,t1,t2,y)
      % calculates statistics on returns
      if isempty(y)
        fprintf('No return data available.\n');
        return;
      endif

      fprintf('Symbol: %s\n',this.finput.symbol);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr. Samples: %d\n',datestr(t1),datestr(t2),this.timestep,numel(y));
      price = this.data.(this.finput.dataCol);
      fprintf('Price: range: [%.2f,%.2f], mean: %.2f, std. dev.: %.2f\n',min(price),max(price),mean(price),std(price));
      fprintf('Price: last: %.2f (z-score %.2f), buy %.2f\n',price(end),(price(end)-mean(price))/std(price),mean(price)-std(price));
      fprintf('Price: upswing potential (max. price - last price): %.2f\n',max(price)-price(end));
      fprintf('Price: downswing potential (last price - min. price): %.2f\n',price(end)-min(price));
      vol = this.volume;
      fprintf('Volume: range: [%d,%d], last value (%d), percentile (%.2f%%)\n',min(vol),max(vol),vol(end),Futil.CalcPercentile(vol,vol(end)));
      fprintf('Returns: range: [%.2f%%,%.2f%%], mean: %.2f%%, std. dev.: %.2f%%\n',min(y),max(y),mean(y),std(y));
      fprintf('Returns: total: %.2f%%, APR=%.2f%%\n',sum(y),Futil.GetAPR(this.timestamp,y));
      tol = 0;
      % returns gt, ls tolerance
      ix1 = y >= tol;
      ix2 = y <= tol;
      fprintf('Returns: gt vs. lt %.2f: %d (pct. %.2f%%, mean %.2f%%) vs. %d (pct. %.2f%%, mean %.2f%%)\n',...
        tol,sum(ix1),Futil.Round(100*(sum(ix1)/numel(y))),mean(y(ix1)),...
            sum(ix2),Futil.Round(100*(sum(ix2)/numel(y))),mean(y(ix2)));
      % returns gt, ls volatility
      ix1 = y >= std(y);
      ix2 = y <= -std(y);
      fprintf('Returns: gt vs. lt %.2f: %d (pct. %.2f%%, mean %.2f%%) vs. %d (pct. %.2f%%, avg. %.2f%%)\n',...
        std(y),sum(ix1),Futil.Round(100*(sum(ix1)/numel(y))),mean(y(ix1)),...
               sum(ix2),Futil.Round(100*(sum(ix2)/numel(y))),mean(y(ix2)));
    endfunction

    function [t,y] = GetReturnData(this)
      if this.flgPctChange
        t = this.data.Date; %this.timestamp;
        y = this.data.pctChange; %this.pctChange;
      else
        this.Calc(); % calculate returns just in case they haven't been calculated
        t = this.timestamp(1:end-1); % n price values => n-1 returns
        y = this.returns;
      endif
    endfunction

  endmethods % Private
endclassdef
