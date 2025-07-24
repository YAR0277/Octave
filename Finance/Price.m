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
      fprintf('Price: last (LP): %.2f, last δP: %.2f\n',price(end),price(end)-price(end-1));
      fprintf('Price: upswing potential (max. price - last price): %.2f\n',max(price)-price(end));
      fprintf('Price: downswing potential (last price - min. price): %.2f\n',price(end)-min(price));

      dp = diff(price);
      id = dp < 0;
      iu = dp > 0;
      iz = dp == 0;
      fprintf('Price: mean(δP<0): %.2f (%d), min(δP<0): %.2f, mean(δP>0): %.2f (%d), max(δP>0): %.2f, num(δP =0) (%d) \n',mean(dp(id)),sum(id),min(dp(id)),mean(dp(iu)),sum(iu),max(dp(iu)),sum(iz));

      prDetrend = Futil.RemoveTrend(price);
      pctLP = Futil.Round(100*(2*std(prDetrend)/price(end)));
      fprintf('Detrend Price: range: [%.2f,%.2f], mean (%.2f), 1σ (%.2f), 2σ (%.2f), 2σ of LP (%.2f%%)\n',...
        min(prDetrend),max(prDetrend),mean(prDetrend),std(prDetrend),2*std(prDetrend),pctLP);
      fprintf('Detrend Price: last: %.2f (z-score %.2f)\n',prDetrend(end),(prDetrend(end)-mean(prDetrend))/std(prDetrend));
      n = numel(prDetrend);
      n1 = sum(prDetrend > mean(prDetrend) + std(prDetrend) | prDetrend < mean(prDetrend) - std(prDetrend));
      n2 = sum(prDetrend > mean(prDetrend) + 2*std(prDetrend) | prDetrend < mean(prDetrend) - 2*std(prDetrend));
      fprintf('Detrend Price: N > [-σ,σ] (%d, %.2f%%), N > [-2σ,2σ] (%d, %.2f%%)\n',n1,100*(n1/n),n2,100*(n2/n));
      vol = this.volume;
      fprintf('Volume: range: [%d,%d], last value (%d), percentile (%.2f%%)\n',min(vol),max(vol),vol(end),Futil.CalcPercentile(vol,vol(end)));
    endfunction

  endmethods % Public

  methods (Access = private)

    function [] = AddStdDevLines(this,x)
      xlim = get(gca(),'xlim');
      n=xlim(2)-xlim(1)+1;
      dx=20;dy=0.5;

      m = mean(x);
      plot([xlim(1):xlim(2)],ones(1,n)*m,'--','color',[0,0.5,0]);%,'LineWidth',Futil.PlotLineWidth);
      text(xlim(1)+dx,m+0.5,sprintf('m=%.2f',m),'color',[0,0.5,0]);

      plot([xlim(1):xlim(2)],ones(1,n)*(m + std(x)),'--','color','red');%,'LineWidth',Futil.PlotLineWidth);
      text(xlim(1)+dx,(m + std(x))+dy,sprintf('m+1σ=%.2f',m+std(x)),'color','red');
      plot([xlim(1):xlim(2)],ones(1,n)*(m + 2*std(x)),'--','color','red');%,'LineWidth',Futil.PlotLineWidth);
      text(xlim(1)+dx,(m + 2*std(x))+dy,sprintf('m+2σ=%.2f',m+2*std(x)),'color','red');

      plot([xlim(1):xlim(2)],ones(1,n)*(m - std(x)),'--','color','red');%,'LineWidth',Futil.PlotLineWidth);
      text(xlim(1)+dx,(m - std(x))-dy,sprintf('m-1σ=%.2f',m-std(x)),'color','red');
      plot([xlim(1):xlim(2)],ones(1,n)*(m - 2*std(x)),'--','color','red');%,'LineWidth',Futil.PlotLineWidth);
      text(xlim(1)+dx,(m - 2*std(x))-dy,sprintf('m-2σ=%.2f',m-2*std(x)),'color','red');
    endfunction

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
##      hold off;

      subplot(2,1,2);
      prDetrend = Futil.RemoveTrend(price);
      plot(t(2:end),prDetrend,'--.','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

      hold on;
      this.AddStdDevLines(prDetrend);

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
