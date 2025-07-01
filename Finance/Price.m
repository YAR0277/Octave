classdef Price < handle
  % class to handle prices of financial data

  properties
    data          % struct of input data
    finput        % Reference to Finput class
    timestamp     % t - timestamp of prices
    timestep      % time interval of price data {'day','week','month','quarter'}
    volume        % volume data
  endproperties

  methods % Public

    function obj = Price(finput)
      % c'tor to create a Price object, input is an Finput object.
      if ~isa(finput, 'Finput')
        return;
      endif

      obj.finput = finput;
      obj.data = readf(finput);
      obj.timestamp = obj.data.Date;
      obj.timestep = Futil.GetTimeStep(obj.timestamp);
      obj.volume = obj.data.Volume;
    endfunction

    function [r] = GetPrices(this)
      r = this.data.(this.finput.dataCol);
    endfunction

    function [r] = Plot(this)
      figure;
      this.DoPlot();
      ## https://stackoverflow.com/questions/67171470/easy-waybuiltin-function-to-put-main-title-in-plot-in-octave
      S = axes('visible','off','title',this.finput.symbol,'FontSize',16);
    endfunction

    function [r] = Stats(this)
      % calculates statistics on prices
      price = this.GetPrices();
      if isempty(price)
        fprintf('No price data available.\n');
        return;
      endif

      fprintf('Symbol: %s\n',this.finput.symbol);
      t1 = this.timestamp(1);
      t2 = this.timestamp(end);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr. Samples: %d\n',datestr(t1),datestr(t2),this.timestep,numel(price));
      fprintf('Price: range: [%.2f,%.2f]\n',min(price),max(price));
      fprintf('Price: last: %.2f (z-score %.2f)\n',price(end),(price(end)-mean(price))/std(price));
      fprintf('Price: upswing potential (max. price - last price): %.2f\n',max(price)-price(end));
      fprintf('Price: downswing potential (last price - min. price): %.2f\n',price(end)-min(price));
      prDetrend = Futil.RemoveTrend(price);
      fprintf('Detrend Price: range: [%.2f,%.2f], mean (%.2f), std.dev. (%.2f)\n',min(prDetrend),max(prDetrend),mean(prDetrend),std(prDetrend));
      vol = this.volume;
      fprintf('Volume: range: [%d,%d], last value (%d), percentile (%.2f%%)\n',min(vol),max(vol),vol(end),Futil.CalcPercentile(vol,vol(end)));
    endfunction

  endmethods % Public

  methods (Access = private)

    function [] = DoPlot(this)

      t=this.timestamp;
      price = this.GetPrices();

      subplot(2,1,1);
      plot(t(2:end),price(2:end),'--.','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

      [xticks,fmt] = Futil.GetDateTicks(this.timestamp);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      ylabel('Price','FontSize',Futil.YLabelFontSize);

      grid on;
      grid minor;
      hold off;

      subplot(2,1,2);
      prDetrend = Futil.RemoveTrend(price);
      plot(t(2:end),prDetrend,'--.','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      ylabel('Price-Detrend','FontSize',Futil.YLabelFontSize);

      grid on;
      grid minor;
      hold off;

    endfunction
  endmethods % Private
endclassdef
