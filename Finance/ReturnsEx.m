classdef ReturnsEx < handle
  % class to compute rate of returns of financial data, used as composition ("has-a") in YahooFile

  properties
    Acceleration
    InFile        % Reference to FidelityFile class
    PlotType      % 1='stem', 2='bar', 3='line', 4='line with velocity & acceleration'
    PurchasePrice %
    StartDay      % calculate returns starting at StartDay
    EndDay        % calculate returns vis-a-vis EndDay
    Velocity
  endproperties

  properties (Access=private)
    A           % days, weeks, months or quarters in a year matrix
  endproperties

  methods % Public

    function obj = ReturnsEx(inFile)
      % c'tor to create a Returns object, input is an FidelityFile object.
      if ~isa(inFile, 'FidelityFile') && ~isa(inFile, 'YahooFile')
        error('Invalid input file class (%s)\n',class(inFile));
      endif
      obj.InFile = inFile;
      obj.PlotType = 3;
      obj.PurchasePrice = NaN;
      obj.StartDay = NaN;
      obj.EndDay = NaN;
    endfunction

    function [r] = get.Acceleration(this)
      [~,y,~] = this.GetReturnData();
      r = diff(y);
    endfunction

    function [r] = get.Velocity(this)
      [~,y,~] = this.GetReturnData();
      r = y;
    endfunction

    function [num,ror,apr] = CalcReturn(this)
      % main method for a simple ror.
      [t,y,z] = this.GetReturnData();
      num = numel(y);
      ror = exp(sum(z))-1;
      ror = Util.Round(ror*100); % as a percent, rounded to 2 decimal places
      apr = Util.GetAPR(t,z);
      apr = Util.Round(apr*100); % as a percent, rounded to 2 decimal places
    endfunction

    function [r] = GetTimestamp(this)
      r = this.InFile.GetTimestamp();
    end

    function [r] = GetValue(this)
      [~,r,~] = this.GetReturnData();
    end

    function [sigma_annual] = GetVolatility(this)
      [~,~,z] = this.GetReturnData();
      sigma_daily = std(z); % daily returns
      sigma_annual = sigma_daily * sqrt(252); % annualize returns
    endfunction

    function [t,y,z] = GetReturnData(this)
      % main method to get return data, arrays of returns for each period.
      timestamp = this.GetTimestamp();

      if isnan(this.StartDay)
        this.StartDay = timestamp(1);
      endif

      if isnan(this.EndDay)
        this.EndDay = timestamp(end);
      endif

      ix = this.StartDay <= timestamp & timestamp <= this.EndDay;
      t = timestamp(ix);

      price = this.InFile.GetValue;
      x = price(ix);
      if ~isnan(this.PurchasePrice)
        x(1) = this.PurchasePrice;
      endif

      t = t(2:end); % n price values => n-1 returns
      y = Util.CalcPctChangeRaw(x);
      z = Util.CalcPctChangeLogRaw(x);
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
      this.DoStats();
    endfunction

  endmethods % Public

  methods (Access = private)

    function [r] = DoStats(this)

      [t,y,z] = this.GetReturnData();

      if isempty(y)
        fprintf('No return data available.\n');
        return;
      endif

      timestep = Util.GetTimeStep(t);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr. Samples: %d\n',datestr(t(1)),datestr(t(end)),timestep,numel(y));
      fprintf('Returns: range: [%.2f%%,%.2f%%], mean: %.2f%%, std. dev.: %.2f%%\n',min(y),max(y),mean(y),std(y));
      [~,ror,apr] = CalcReturn(this);
      fprintf('Returns: cumulative: %.2f%%, APR=%.2f%%\n',ror,apr);
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

      y = Util.Round(y*100); % as a percent, rounded to 2 decimal places
      z = Util.Round(z*100); % as a percent, rounded to 2 decimal places

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

      y = Util.Round(y*100); % as a percent, rounded to 2 decimal places
      z = Util.Round(z*100); % as a percent, rounded to 2 decimal places

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

      y = Util.Round(y*100); % as a percent, rounded to 2 decimal places
      z = Util.Round(z*100); % as a percent, rounded to 2 decimal places

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

      y = Util.Round(y*100); % as a percent, rounded to 2 decimal places
      z = Util.Round(z*100); % as a percent, rounded to 2 decimal places

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
