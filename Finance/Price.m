classdef Price < handle
  % class to handle prices of financial data

  properties
    fidelityFile  % Reference to FidelityFile class
    timestamp     % t - timestamp of prices
    timestep      % time interval of price data {'day','week','month','quarter'}
    volume        % volume data
  endproperties

  methods % Public

    function obj = Price(fidelityFile)
      % c'tor to create a Price object, input is an FidelityFile object.
      if ~isa(fidelityFile, 'FidelityFile')
        return;
      endif

      obj.fidelityFile = fidelityFile;
      obj.timestamp = fidelityFile.GetTimestamp; %obj.data.Date;
      obj.timestep = Util.GetTimeStep(obj.timestamp);
      obj.volume = fidelityFile.GetVolume; %obj.data.Volume;
    endfunction

    function [r] = GetPrices(this)
      r = this.fidelityFile.data.(this.fidelityFile.dataCol);
    endfunction

    function [r] = Plot(this)
      figure;
      this.DoPlot();
      ## https://stackoverflow.com/questions/67171470/easy-waybuiltin-function-to-put-main-title-in-plot-in-octave
      S = axes('visible','off','title',this.fidelityFile.symbol,'FontSize',16);
    endfunction

    function [r] = Stats(this)
      % calculates statistics on prices
      price = this.GetPrices();
      if isempty(price)
        fprintf('No price data available.\n');
        return;
      endif

      fprintf('Symbol: %s\n',this.fidelityFile.symbol);
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
      fprintf('Volume: range: [%d,%d], last value (%d), percentile (%.2f%%)\n',min(vol),max(vol),vol(end),Util.CalcPercentile(vol,vol(end)));
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
  endmethods % Private
endclassdef
