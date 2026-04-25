classdef MACDIday < MACDEx
  % MACDIday - Moving Average Convergence/Divergence, Ex = redesign
  % https://en.wikipedia.org/wiki/MACD
  % https://www.investopedia.com/terms/m/macd.asp

  methods % Public

    function obj = MACDIday(inFile)
      obj = obj@MACDEx(inFile);
      obj.wndLengthFast = 8;
      obj.wndLengthSlow = 21;
      obj.wndLengthSignal = 5;
    endfunction

    function [] = Plot(this,t,x)
      figure;
      this.Subplot(t,x);
    endfunction
  endmethods %Public

  methods (Access = private)

    function [] = Subplot(this,t,x)

      [signal,macd,fast,slow] = this.CalcMACD(x);

      ax1=subplot(3,1,1);

      tod = (t-floor(t))*86400; % time of day is seconds since midnight
      plot(tod,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      Util.AddWatermark(ax1,this.InFile.Ticker);

      hold on;
      plot(tod,fast,'-','color',Color.Magenta,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      plot(tod,slow,'-','color',Color.Brown,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      xt = get(gca, 'xtick');
      labels = arrayfun(@(x) sprintf('%02d:%02d', ...
                      floor(x/3600),floor(mod(x,3600)/60)), ...
                      xt, 'UniformOutput', false);
      set(ax1,'xticklabel',[]);
      xlim([xt(1) xt(end)]);

      ylabel('Price','FontSize',Constant.YLabelFontSize);
      legend('price','fast','slow','location','northwest');

      grid on;
      grid minor;
      hold off;

      ax2=subplot(3,1,2);
      volume = this.InFile.GetVolume;
      bar(tod,volume,'facecolor',Color.LightGrey);

      xlim([xt(1) xt(end)]);
      set(ax2,'xticklabel',[]);

      yticks = get(ax2,"YTick");
      ticklabels = arrayfun(@(x) strcat(num2str(x),'k'), yticks/1000, "UniformOutput", false);
      yticklabels(ticklabels);
      ylabel('Volume','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;

      ax3=subplot(3,1,3);
      plot(tod,signal,'-','color',Color.LightBlue,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      plot(tod,macd,'-','color',Color.Orange,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      plot(tod,macd-signal,'--','color',Color.Red,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.AddMidLine(0.0);

      xlim([xt(1) xt(end)]);
      set(ax3, 'xticklabel', labels);

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
