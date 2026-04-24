classdef MACDEx < handle
  % MACDEx - Moving Average Convergence/Divergence, Ex = redesign
  % https://en.wikipedia.org/wiki/MACD
  % https://www.investopedia.com/terms/m/macd.asp

  properties
    Acceleration
    InFile
    Velocity
    wndLengthFast % window length fast
    wndLengthSlow % window length fast
    wndLengthSignal % window length signal
  endproperties

  methods % Public

    function obj = MACDEx(inFile)
      % c'tor to create a Price object, input is an FidelityFile object.
      if ~isa(inFile, 'FidelityFile') && ~isa(inFile, 'YahooFile')
        error('Invalid input file class (%s)\n',class(inFile));
      endif
      obj.InFile = inFile;
      obj.wndLengthFast = 12;
      obj.wndLengthSlow = 26;
      obj.wndLengthSignal = 9;
    endfunction

    function [r] = get.Acceleration(this,price)
      [signal,macd,~,~] = this.CalcMACD(price);
      r = macd-signal;
    endfunction

    function [r] = get.Velocity(this,price)
      [~,macd,~,~] = this.CalcMACD(price);
      r = macd;
    endfunction

    function [this] = set.WndLengthFast(this,x)
      this.wndLengthFast = x;
    endfunction

    function [this] = set.WndLengthSlow(this,x)
      this.wndLengthSlow = x;
    endfunction

    function [this] = set.WndLengthSignal(this,x)
      this.wndLengthSignal = x;
    endfunction

    function [] = AddMidLine(this,y)
      xlim = get(gca(),'xlim');
      n=xlim(2)-xlim(1)+1;
      plot([xlim(1):xlim(2)],ones(1,n)*y,'-','color',Color.LightGrey,'LineWidth',Constant.PlotLineWidth);
    endfunction

    function [r,macd,fast,slow] = CalcMACD(this,x)
      % calculates the moving average convergence divergence
      fast = MovingAvg.EMA(x,this.wndLengthFast);
      slow = MovingAvg.EMA(x,this.wndLengthSlow);
      macd = fast - slow; % macd line
      r = MovingAvg.EMA(macd,this.wndLengthSignal); % signal line
    endfunction

    function [] = Plot(this,ticker,t,x)
      figure;
      this.Subplot(t,x);
      ## https://stackoverflow.com/questions/67171470/easy-waybuiltin-function-to-put-main-title-in-plot-in-octave
      S = axes('visible','off','title',ticker,'FontSize',16);
    endfunction
  endmethods %Public

  methods (Access = private)
    function [] = Subplot(this,t,x)

      [signal,macd,fast,slow] = this.CalcMACD(x);
      volume = this.InFile.GetVolume;

      ax1=subplot(3,1,1);
      plot(t,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      plot(t,fast,'-','color',Color.Magenta,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      plot(t,slow,'-','color',Color.Brown,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(t);
      set(ax1,"xticklabel",[]);
      xlim([xticks(1) xticks(end)]);

      ylabel('Price','FontSize',Constant.YLabelFontSize);
      legend('price','fast','slow','location','northwest');

      grid on;
      grid minor;
      hold off;

      ax2=subplot(3,1,2);
      bar(t,volume);

      set(ax2,"xticklabel",[]);
      xlim([xticks(1) xticks(end)]);

      yticks = get(ax2,"YTick");
      ticklabels = arrayfun(@(x) strcat(num2str(x),'k'), yticks/1000, "UniformOutput", false);
      yticklabels(ticklabels);

      ylabel('Volume','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;

      ax3=subplot(3,1,3);
      plot(t,signal,'-','color',Color.LightBlue,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      plot(t,macd,'-','color',Color.Orange,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      plot(t,macd-signal,'--','color',Color.Red,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.AddMidLine(0.0);

      set(ax3,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      ylabel('MACD','FontSize',Constant.YLabelFontSize);
      legend('signal','macd','delta','location','northwest');

      grid on;
      grid minor;
      hold off;

      pos1 = get(ax1,"outerposition"); % [left,bottom,width,height]
      pos2 = get(ax2,"outerposition");
      pos3 = get(ax3,"position");
      gap = 0.04;
      pos1(1) = pos3(1);  % left
      pos2(1) = pos3(1);
      pos1(2) -= gap/2;   % bottom
      pos2(2) += gap/2;
      pos1(3) = pos3(3);  % width
      pos2(3) = pos3(3);
      pos1(4) += gap/2;   % height
      pos2(4) -= 2*gap;
      set(ax1, "position", pos1);
      set(ax2, "position", pos2);

      linkaxes([ax1, ax2], "x");

    endfunction
  endmethods
endclassdef
