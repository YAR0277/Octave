classdef BBEx < handle
  % Bollinger Bands
  % https://en.wikipedia.org/wiki/Bollinger_Bands
  % https://www.investopedia.com/terms/b/bollingerbands.asp

  properties
    alpha     % smoothing parameter: alpha -> 1 (less smoothing), alpha -> 0 (more smoothing)
    InFile    % Reference to YahooFile or FidelityFile class
    maType    % type of Moving Average = {"SMA","MMA","EMA","WMA"}
    wght      % weighting of data
    wlen      % length of window or smoothing period
  endproperties

  methods % Public

    function obj = BBEx(inFile)
      % c'tor to create an BB object, input is an FidelityFile object.
      if ~isa(inFile, 'FidelityFile') && ~isa(inFile, 'YahooFile')
        error('Invalid input file class (%s)\n',class(inFile));
      endif
      obj.InFile = inFile;

      obj.alpha = 0.1;
      obj.maType = "SMA"; % default
      obj.wlen = 14;
    endfunction

    function [r] = CalcMA(this,x)
      % calculates the moving average according to moving average type
      switch this.maType
        case "EMA"
          r = MovingAvg.EMA(x,this.wlen,this.alpha);
        case "MMA"
          r = MovingAvg.MMA(x,this.wlen);
        case "SMA"
          r = MovingAvg.SMA(x,this.wlen);
        case "WMA"
          r = MovingAvg.WMA(x,this.w,this.wlen);
        otherwise
      endswitch
    endfunction

    function [r] = GetPrices(this)
      r = this.InFile.Data.(this.InFile.DataCol);
    endfunction

    function [r] = GetTimestamp(this)
      r = this.InFile.GetTimestamp();
    end

    function [] = Plot(this)
      figure;
      this.Subplot();
    endfunction

    function [] = Subplot(this)

      x=this.CalcMA(this.GetPrices);
      t=this.GetTimestamp;

      subplot(2,1,1);
      plot(t,this.GetPrices,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      Util.AddWatermark(gca,this.InFile.Ticker);

      hold on;
      [lower,upper] = this.AddBandLines(t,x);

      [xticks,fmt] = Util.GetDateTicks(this.GetTimestamp);
      set(gca,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('Bollinger Bands','FontSize',Constant.YLabelFontSize);
      legend(this.maType,'FontSize',Constant.LegendFontSize);

      grid on;
      grid minor;
      hold off;

      subplot(2,1,2);
      pctB = ((this.GetPrices - lower) ./ (upper - lower) );
      plot(t,pctB,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      this.AddMidLine(0.5);

      set(gca,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylabel('%b','FontSize',Constant.YLabelFontSize);

      grid on;
      grid minor;
      hold off;
    endfunction

    function [] = SetAlpha(this,alpha)
      this.alpha = alpha;
    endfunction

    function [] = SetType(this,maType)
    % BB types = {"SMA","MMA","EMA","WMA"}.
      this.maType = maType;
    endfunction

    function [] = SetWeightVector(this,w)
      this.wght = w;
    endfunction

    function [] = SetWindowLength(this,wlen)
      this.wlen = wlen;
    endfunction

  endmethods %Public

  methods (Access = private)
    function [lower,upper] = AddBandLines(this,t,x)
      sig = std(x);
      lower = x - sig;
      upper = x + sig;

      plot(t,lower,'--','color','green','LineWidth',Constant.PlotLineWidth);
      plot(t,upper,'--','color','red','LineWidth',Constant.PlotLineWidth);
    endfunction

    function [] = AddMidLine(this,y)
      xlim = get(gca(),'xlim');
      n=xlim(2)-xlim(1)+1;
      plot([xlim(1):xlim(2)],ones(1,n)*y,'--','color','red','LineWidth',Constant.PlotLineWidth);
    endfunction
  endmethods
endclassdef
