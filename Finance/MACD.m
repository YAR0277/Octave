classdef MACD < handle
  % MACD - Moving Average Convergence/Divergence
  % https://en.wikipedia.org/wiki/MACD
  % https://www.investopedia.com/terms/m/macd.asp

  properties
    data      % struct of input data
    finput    % Reference to Finput class
    price     % x - prices of investment
    timestamp % t - timestamp of prices
    wndLengthFast % window length fast
    wndLengthSlow % window length fast
    wndLengthSignal % window length signal
  endproperties

  methods % Public

    function obj = MACD(finput)
      % c'tor to create an MACD object, input is an Finput object.
      if ~isa(finput, 'Finput')
        return;
      endif

      obj.finput = finput;
      obj.data = readf(finput);
      obj.price = obj.data.(finput.dataCol);
      obj.timestamp = obj.data.Date;
      obj.wndLengthFast = 12;
      obj.wndLengthSlow = 26;
      obj.wndLengthSignal = 9;
    endfunction

    function [r,macd,fast,slow] = CalcMACD(this,x)
      % calculates the moving average convergence divergence
      fast = MovingAvg.EMA(x,this.wndLengthFast);
      slow = MovingAvg.EMA(x,this.wndLengthSlow);
      macd = fast - slow; % macd line
      r = MovingAvg.EMA(macd,this.wndLengthSignal); % signal line
    endfunction

    function [] = Plot(this)
      figure;
      this.Subplot();
      ## https://stackoverflow.com/questions/67171470/easy-waybuiltin-function-to-put-main-title-in-plot-in-octave
      S = axes('visible','off','title',this.finput.symbol,'FontSize',16);
    endfunction

    function [] = Subplot(this)

      t=this.timestamp;
      [signal,macd,fast,slow] = this.CalcMACD(this.price);

      subplot(2,1,1);
      plot(t,this.price,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      plot(t,fast,'-','color','magenta','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      plot(t,slow,'-','color',[0.65,0.16,0.16],'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(this.timestamp);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      ylabel('Price','FontSize',Constant.YLabelFontSize);
      legend('price','fast','slow','location','northwest');

      grid on;
      grid minor;
      hold off;

      subplot(2,1,2);
      plot(t,signal,'-','color','red','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      plot(t,macd,'-','color','blue','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.AddMidLine(0.0);

      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      ylabel('MACD','FontSize',Constant.YLabelFontSize);
      legend('signal','macd','location','northwest');

      grid on;
      grid minor;
      hold off;

    endfunction
  endmethods %Public

  methods (Access = private)
    function [] = AddMidLine(this,y)
      xlim = get(gca(),'xlim');
      n=xlim(2)-xlim(1)+1;
      plot([xlim(1):xlim(2)],ones(1,n)*y,'--','color',[0.5,0.5,0.5],'LineWidth',Constant.PlotLineWidth);
    endfunction
  endmethods
endclassdef
