classdef RSI < handle
  % Relative Strength Index
  % https://en.wikipedia.org/wiki/Relative_strength_index
  % https://www.investopedia.com/terms/r/rsi.asp

  properties
    alpha     % smoothing parameter: alpha -> 1 (less smoothing), alpha -> 0 (more smoothing)
    finput    % Reference to Finput class
    price     % x - prices of investment
    rsiType   % type of RSI = {"SMA","MMA","EMA","WMA"}
    timestamp % t - timestamp of prices
    w         % weighting of data
    wlen      % length of window or smoothing period
  endproperties

  methods % Public

    function obj = RSI(finput)
      % c'tor to create an RSI object, input is an Finput object.
      if ~isa(finput, 'Finput')
        return;
      endif

      obj.finput = finput;
      obj.rsiType = "SMA"; % default
      obj.alpha = 0.1;
      obj.wlen = 14;
      [obj.timestamp,obj.price] = showf(finput);
    endfunction

    function [r] = CalcRSI(this)
      % calculates the Relative Strength Index with window length wlen.
      r = 100 - (100 ./ (1 + this.CalcRS()));
    endfunction

    function [r] = CalcRS(this)
      % calculates the Relative Strength with window length wlen.
      dx = diff(this.price);

      u(dx  > 0) = dx(dx > 0);
      u(dx <= 0) = 0;

      d(dx  < 0) = -dx(dx < 0);
      d(dx >= 0) = 0;

      switch this.rsiType
        case "EMA"
          r = MovingAvg.EMA(u,this.alpha)./MovingAvg.EMA(d,this.alpha);
        case "MMA"
          r = MovingAvg.MMA(u,this.wlen)./MovingAvg.MMA(d,this.wlen);
        case "SMA"
          r = MovingAvg.SMA(u,this.wlen)./MovingAvg.SMA(d,this.wlen);
        case "WMA"
          r = MovingAvg.WMA(u,this.w,this.wlen)./MovingAvg.WMA(d,this.w,this.wlen);
        otherwise
      endswitch
    endfunction

    function [] = Compare(this)
      figure;
      hold on;
      this.DoPlotRSI("SMA");
      this.DoPlotRSI("EMA");
      this.DoPlotRSI("MMA");
      this.DoPlotRSI("WMA");
      datetick('x','YY','keepticks');
      ylim([0 100]);
      ylabel('RSI');
      title('Comparison of Relative Strength Indices');
      this.AddGuideLines(70,30);
      this.AddRectgangle(numel(this.price),70,30);
      grid on;
      legend('SMA','EMA','MMA','WMA');
      hold off;
    endfunction

    function [] = PlotRSI(this,rsiType)

      if nargin < 2
        fprintf('call is ''PlotRSI(rsiType)'' where rsiType = {SMA,EMA,MMA,WMA}\n');
        return;
      endif

      figure;
      hold on;
      grid on;
      grid minor;
      this.DoPlotRSI(rsiType);
      datetick('x','YY','keepticks');
      ylim([0 100]);
      this.AddGuideLines(70,30);
      this.AddRectgangle(numel(this.price),70,30);
      ylabel('RSI');
      legend(rsiType);
      title(this.finput.symbol);
      hold off;
    endfunction

    function [] = PlotRS(this,rsiType)
      figure;
      hold on;
      grid on;
      grid minor;
      this.DoPlotRS(rsiType);
      datetick('x','YY','keepticks');
      ylabel('RS');
      legend(rsiType);
      title(this.finput.symbol);
      hold off;
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

      plot([xlim(1):xlim(2)],ones(1,n)*high,'--','color','red','linewidth',0.1);
      text(xlim(1)+dx,high+dy,'Overbought > 70');

      plot([xlim(1):xlim(2)],ones(1,n)*low,'--','color','red','linewidth',0.1);
      text(xlim(1)+dx,low-dy,'Oversold < 30');
    endfunction

    function [] = DoPlotRS(this,rsiType)

      this.SetType(rsiType);

      x=this.CalcRS();
      t=this.timestamp(2:end);
      plot(t,x,'--.');
    endfunction

    function [] = DoPlotRSI(this,rsiType)

      this.SetType(rsiType);

      x=this.CalcRSI();
      t=this.timestamp(2:end);
      plot(t,x,'--.');
    endfunction

    function [] = AddRectgangle(~,n,high,low)
##      rectangle('Position',[0,low,n,high-low],'FaceColor','lightgray','EdgeColor','none');
    endfunction

  endmethods
endclassdef
