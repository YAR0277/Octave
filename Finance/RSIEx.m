classdef RSIEx < handle
  % Relative Strength Index
  % https://en.wikipedia.org/wiki/Relative_strength_index
  % https://www.investopedia.com/terms/r/rsi.asp

  properties
    alpha     % smoothing parameter: alpha -> 1 (less smoothing), alpha -> 0 (more smoothing)
    InFile    % Reference to YahooFile or FidelityFile class
    rsiType   % type of RSI = {"SMA","MMA","EMA","WMA"}
    w         % weighting of data
    wlen      % length of window or smoothing period
  endproperties

  methods % Public

    function obj = RSIEx(inFile)
      % c'tor to create an RSI object, input is a YahooFile or FidelityFile object.
      if ~isa(inFile, 'FidelityFile') && ~isa(inFile, 'YahooFile')
        error('Invalid input file class (%s)\n',class(inFile));
      endif
      obj.InFile = inFile;

      obj.alpha = 0.1;
      obj.rsiType = "SMA"; % default
      obj.wlen = 14;
      obj.w = 1:14;
    endfunction

    function [r] = GetTimestamp(this)
      r = this.InFile.GetTimestamp();
      r = r(2:end);
    end

    function [r] = GetValue(this)
      r = this.CalcRSI();
    end

    function [] = Compare(this)
      figure;
      hold on;
      this.SetType("SMA");
      this.Subplot();
      this.SetType("EMA");
      this.Subplot();
      this.SetType("MMA");
      this.Subplot();
      this.SetType("WMA");
      this.Subplot();
      datetick('x','YY','keepticks');
      ylim([0 100]);
      ylabel('RSI');
      title('Comparison of Relative Strength Indices','FontSize', Constant.TitleFontSize);
      this.AddGuideLines(70,30);
      grid on;
      legend({'SMA','EMA','MMA','WMA'},'FontSize',Constant.LegendFontSize);
      hold off;
    endfunction

    function [] = Plot(this)
      figure;
      hold on;
      this.Subplot();

      timestamp = this.GetTimestamp();
      [xticks,fmt] = Util.GetDateTicks(timestamp);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([timestamp(1) timestamp(end)]);

      ylim([0 100]);
      this.AddGuideLines(70,30);
      ylabel('RSI','FontSize',Constant.YLabelFontSize);
      legend(this.rsiType,'FontSize',Constant.LegendFontSize);

      Util.AddWatermark(ax,this.InFile.Ticker);

      grid on;
      grid minor;
      hold off;
    endfunction

    function [] = PlotAggregate(this,dt)
      TimeSeries.PlotAggregate(this,dt);
    endfunction

    function [] = PlotTrend(this,wlen)
      TimeSeries.PlotTrend(this,wlen);
    endfunction

    function [] = SetAlpha(this,alpha)
      this.alpha = alpha;
    endfunction

    function [] = SetType(this,rsiType)
    % RSI types = {"SMA","MMA","EMA","WMA"}.
      this.rsiType = rsiType;
    endfunction

    function [] = SetWeightVector(this,w)
      this.w = w;
    endfunction

    function [] = SetWindowLength(this,wlen)
      this.wlen = wlen;
    endfunction

  endmethods %Public

  methods (Access = private)
    function [] = AddGuideLines(this,high,low)
      xlim = get(gca(),'xlim');
      n=xlim(2)-xlim(1)+1;
      dx=100;dy=5;

      plot([xlim(1):xlim(2)],ones(1,n)*high,'--','color','red','LineWidth',Constant.PlotLineWidth);
      text(xlim(1)+dx,high+dy,'Overbought > 70');

      plot([xlim(1):xlim(2)],ones(1,n)*low,'--','color','red','LineWidth',Constant.PlotLineWidth);
      text(xlim(1)+dx,low-dy,'Oversold < 30');
    endfunction

    function [r] = CalcRSI(this)
      % calculates the Relative Strength Index with window length wlen.
      r = 100 - (100 ./ (1 + this.CalcRS()));
    endfunction

    function [r] = CalcRS(this)
      % calculates the Relative Strength with window length wlen.
      price = this.InFile.GetValue;
      dx = diff(price);

      u(dx  > 0) = dx(dx > 0);
      u(dx <= 0) = 0;

      d(dx  < 0) = -dx(dx < 0);
      d(dx >= 0) = 0;

      switch this.rsiType
        case "EMA"
          r = MovingAvg.EMA(u,this.wlen,this.alpha)./MovingAvg.EMA(d,this.wlen,this.alpha);
        case "MMA"
          r = MovingAvg.MMA(u,this.wlen)./MovingAvg.MMA(d,this.wlen);
        case "SMA"
          r = MovingAvg.SMA(u,this.wlen)./MovingAvg.SMA(d,this.wlen);
        case "WMA"
          r = MovingAvg.WMA(u,this.w,this.wlen)./MovingAvg.WMA(d,this.w,this.wlen);
        otherwise
      endswitch
    endfunction

    function [] = Subplot(this)
      x=this.CalcRSI();
      t=this.GetTimestamp();
      plot(t,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
    endfunction
  endmethods
endclassdef
