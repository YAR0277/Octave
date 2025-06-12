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
      fprintf('Time Period: [%s,%s]\n',datestr(t1),datestr(t2));
      fprintf('Number of Samples: %d\n',numel(y));
      fprintf('Max. return: %.2f%%\n',max(y));
      fprintf('Min. return: %.2f%%\n',min(y));
      fprintf('Avg. return: %.2f%%\n',mean(y));
      fprintf('Total return: %.2f%%, APR=%.2f%%\n',sum(y),sum(y)*(365/numel(y)));
      fprintf('Volatility of returns: %.2f%%\n',std(y)); % standard deviation = volatility
      tol = 0;
      % returns > tolerance
      ix = y >= tol;
      fprintf('Number of Returns >= %.2f: %d (pct. of total %.2f%%, avg. return %.2f%%)\n',...
        tol,sum(ix),Futil.Round(100*(sum(ix)/numel(y))),mean(y(ix)));
      % returns <= tolerance
      ix = y <= tol;
      fprintf('Number of Returns <= %.2f: %d (pct. of total %.2f%%, avg. return %.2f%%)\n',...
        tol,sum(ix),Futil.Round(100*(sum(ix)/numel(y))),mean(y(ix)));
      % returns >= volatility
      ix = y >= std(y);
      fprintf('Number of Returns >= %.2f: %d (pct. of total %.2f%%, avg. return %.2f%%)\n',...
        std(y),sum(ix),Futil.Round(100*(sum(ix)/numel(y))),mean(y(ix)));
      % returns <= -volatility
      ix = y <= -std(y);
      fprintf('Number of Returns <= %.2f: %d (pct. of total %.2f%%, avg. return %.2f%%)\n',...
        -std(y),sum(ix),Futil.Round(100*(sum(ix)/numel(y))),mean(y(ix)));
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
