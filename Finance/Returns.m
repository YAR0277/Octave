classdef Returns < handle
  % class to compute rate of returns of financial data

  properties
    Acceleration
    InFile        % Reference to FidelityFile class
    rateOfReturn  % rate of return
    rateOfReturnApproximate  % rate of return using natural log approximation
    timestamp     % t - timestamp of prices
    timestep      % time interval of price data {'day','week','month','quarter'}
    PlotType      % 1='stem', 2='bar', 3='line', 4='line with velocity & acceleration'
    startDay      % calculate returns starting at startDay
    endDay        % calculate returns vis-a-vis endDay
    Velocity
    volume        % volume data
  endproperties

  properties (Access=private)
    A           % days, weeks, months or quarters in a year matrix
  endproperties

  methods % Public

    function obj = Returns(inFile)
      % c'tor to create a Returns object, input is an FidelityFile object.
      if ~isa(inFile, 'FidelityFile') && ~isa(inFile, 'YahooFile')
        error('Invalid input file class (%s)\n',class(inFile));
      endif

      obj.InFile = inFile;
      obj.timestamp = inFile.GetTimestamp;
      obj.timestep = Util.GetTimeStep(obj.timestamp);
      obj.PlotType = 3;
      obj.startDay = obj.timestamp(1);
      obj.endDay = Util.GetDatenumToday();
      obj.volume = inFile.GetVolume;
      obj.SetReturnData;
    endfunction

    function [r] = get.PlotType(this)
      r = this.PlotType;
    endfunction

    function [] = set.PlotType(this,y)
      this.PlotType = y;
    endfunction

    function [r] = get.Acceleration(this)
      r = diff(this.rateOfReturn);
    endfunction

    function [r] = get.Velocity(this)
      r = this.rateOfReturn;
    endfunction

    function [this] = set.EndDay(this,date)
      % [] = EndDay(date) where date='2025-09-23'
      this.endDay = Util.GetDatenum(date);
    endfunction

    function [this] = set.StartDay(this,date)
      % [] = StartDay(date) where date='2025-09-23'
      this.startDay = Util.GetDatenum(date);
    endfunction

    function [r] = GetTimestamp(this)
      r = this.timestamp;
    end

    function [r] = GetValue(this)
      r = this.RateOfReturn;
    end

    function [t,y,z] = GetReturnData(this)
      t = this.timestamp(1:end-1); % n price values => n-1 returns
      y = this.rateOfReturn;
      z = this.rateOfReturnApproximate;
    endfunction

    function [] = SetReturnData(this)

      ix = this.startDay <= this.timestamp & this.timestamp <= this.endDay;
      t = this.timestamp(ix);
      price = this.InFile.GetValue;
      x = price(ix);

      this.rateOfReturn = Util.CalcPctChange(x);
      this.rateOfReturnApproximate = Util.CalcPctChangeLog(x);
    endfunction

    function [r] = Plot(this)
      % plots returns
      switch this.PlotType
        case 1
          this.PlotStem();
        case 2
          this.PlotBar();
        case 3
          this.PlotLine();
        case 4
          this.PlotLineEx();
        otherwise
          this.PlotBar();
      endswitch
    endfunction

    function [] = PlotAggregate(this,dt)
      TimeSeries.PlotAggregate(this,dt);
    endfunction

    function [] = PlotTrend(this,wlen)
      TimeSeries.PlotTrend(this,wlen);
    endfunction

    function [r] = Subplot(this)
      % plots returns, used in subplot command (see plotf.m).
      [t,y,z] = this.GetReturnData();
      if length(t) < Constant.MinLengthReturns || length(y) < Constant.MinLengthReturns
        return;
      endif

      plot(t,y,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('Rate of Return(%)','FontSize',14);
      title(this.InFile.symbol,'FontSize',16);
      grid on;
      grid minor;
    endfunction

    function [r] = Stats(this)
      % calculates statistics on returns
      [t,y,z] = this.GetReturnData();
      this.DoStats(t(1),t(end),y,z);
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

    function [r] = DoStats(this,t1,t2,y,z)
      % calculates statistics on returns
      if isempty(y)
        fprintf('No return data available.\n');
        return;
      endif

      fprintf('Time Period: [%s,%s], Time Step: %s, Nr. Samples: %d\n',datestr(t1),datestr(t2),this.timestep,numel(y));
      fprintf('Returns: range: [%.2f%%,%.2f%%], mean: %.2f%%, std. dev.: %.2f%%\n',min(y),max(y),mean(y),std(y));
      fprintf('Returns: total: %.2f%%, APR=%.2f%%\n',sum(z),Util.GetAPR(this.timestamp,z));
      tol = 0;
      % returns gt, ls tolerance
      ix1 = y >= tol;
      ix2 = y <= tol;
      fprintf('Returns: gt vs. lt %.2f: %d (pct. %.2f%%, mean %.2f%%) vs. %d (pct. %.2f%%, mean %.2f%%)\n',...
        tol,sum(ix1),Util.Round(100*(sum(ix1)/numel(y))),mean(y(ix1)),...
            sum(ix2),Util.Round(100*(sum(ix2)/numel(y))),mean(y(ix2)));
      % returns gt, ls volatility
      ix1 = y >= std(y);
      ix2 = y <= -std(y);
      fprintf('Returns: gt vs. lt %.2f: %d (pct. %.2f%%, mean %.2f%%) vs. %d (pct. %.2f%%, avg. %.2f%%)\n',...
        std(y),sum(ix1),Util.Round(100*(sum(ix1)/numel(y))),mean(y(ix1)),...
               sum(ix2),Util.Round(100*(sum(ix2)/numel(y))),mean(y(ix2)));
    endfunction

    function [] = PlotBar(this)
      % plot returns as bar plot

      [t,y,z] = this.GetReturnData();
      if isempty(t) || isempty(y)
        fprintf('No return data found to plot.\n');
        return;
      endif

      figure;
      bar(t,y);

      [xticks,fmt] = Util.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('Rate of Return (%)','FontSize',16);
      grid on;
    endfunction

    function [] = PlotLine(this)
      % plot returns as line plot

      [t,y,z] = this.GetReturnData();
      if length(t) < Constant.MinLengthReturns || length(y) < Constant.MinLengthReturns
        fprintf('Length of return data (l.t. %d) insufficient to plot.\n',Constant.MinLengthReturns);
        return;
      endif

      figure;
      hold on;
      plot(t,y,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      plot(t,z,'o','Color',Color.Brown);

      [xticks,fmt] = Util.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('Rate of Return(%)','FontSize',14);
      grid on;
      hold off;
    endfunction

    function [] = PlotLineEx(this)
      % plot returns as line plot

      [t,y,z] = this.GetReturnData();
      if length(t) < Constant.MinLengthReturns || length(y) < Constant.MinLengthReturns
        fprintf('Length of return data (l.t. %d) insufficient to plot.\n',Constant.MinLengthReturns);
        return;
      endif

      figure;
      hold on;
      plot(t,this.Velocity,'--.','Color',Color.Magenta,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      plot(t(1:end-1),this.Acceleration,'--','Color',Color.Brown);

      [xticks,fmt] = Util.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('Rate of Return(%)','FontSize',14);
      legend('velocity','acceleration');
      grid on;
      hold off;
    endfunction

    function [] = PlotStem(this)
      % plots returns as stem plot

      [t,y,z] = this.GetReturnData();
      if isempty(t) || isempty(y)
        fprintf('No return data found to plot.\n');
        return;
      endif

      figure;
      stem(t,y);

      [xticks,fmt] = Util.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('Rate of Return (%)','FontSize',16);
      grid on;
      grid minor;
    endfunction
  endmethods % Private
endclassdef
