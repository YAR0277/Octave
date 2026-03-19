classdef MACDIday < MACDEx
  % MACDIday - Moving Average Convergence/Divergence, Ex = redesign
  % https://en.wikipedia.org/wiki/MACD
  % https://www.investopedia.com/terms/m/macd.asp

  methods % Public

    function obj = MACDIday()
      obj = obj@MACDEx();
      obj.wndLengthFast = 12;
      obj.wndLengthSlow = 26;
      obj.wndLengthSignal = 9;
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

      subplot(2,1,1);
      tod = (t-floor(t))*86400; % time of day is seconds since midnight
      plot(tod,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      plot(tod,fast,'-','color','magenta','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      plot(tod,slow,'-','color',[0.65,0.16,0.16],'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      xt = get(gca, 'xtick');
      labels = arrayfun(@(x) sprintf('%02d:%02d', ...
                      floor(x/3600),floor(mod(x,3600)/60)), ...
                      xt, 'UniformOutput', false);
      set(gca, 'xticklabel', labels);

      ylabel('Price','FontSize',Constant.YLabelFontSize);
      legend('price','fast','slow','location','northwest');

      grid on;
      grid minor;
      hold off;

      subplot(2,1,2);
      plot(tod,signal,'-','color','red','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      plot(tod,macd,'-','color','blue','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
      this.AddMidLine(0.0);

      xt = get(gca, 'xtick');
      labels = arrayfun(@(x) sprintf('%02d:%02d', ...
                      floor(x/3600),floor(mod(x,3600)/60)), ...
                      xt, 'UniformOutput', false);
      set(gca, 'xticklabel', labels);

      ylabel('MACD','FontSize',Constant.YLabelFontSize);
      legend('signal','macd','location','northwest');

      grid on;
      grid minor;
      hold off;
    endfunction
  endmethods
endclassdef
