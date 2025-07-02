classdef StoOsc < handle
  % StoOsc - Stochastic Oscillator
  % https://en.wikipedia.org/wiki/Stochastic_oscillator
  % https://www.investopedia.com/terms/s/stochasticoscillator.asp
  % https://www.investopedia.com/ask/answers/06/daytradingstochastic.asp

  properties
    data      % struct of input data
    finput    % Reference to Finput class
    high      % high prices
    low       % low prices
    price     % closing (dataCol) prices of investment
    timestamp % t - timestamp of prices
    numPeriods    % number of days in past over which to calculate oscillator
    wndLengthSlow % window length fast
  endproperties

  methods % Public

    function obj = StoOsc(finput)
      % c'tor to create an StoOsc object, input is an Finput object.
      if ~isa(finput, 'Finput')
        return;
      endif

      obj.finput = finput;
      obj.data = readf(finput);
      obj.high = obj.data.High;
      obj.low = obj.data.Low;
      obj.price = obj.data.(finput.dataCol);
      obj.timestamp = obj.data.Date;
      obj.wndLengthSlow = 3;
      obj.numPeriods = 14;
    endfunction

    function [oscSlow,oscFast] = CalcSO(this)
      % calculates the moving average convergence divergence
      len = length(this.price);
      n = this.numPeriods;

      if len <= n
        fprintf('Number of prices (%d) must be larger than number of periods.\n',len,n);
        return;
      endif

      oscSlow = NaN(len,1);
      oscFast = NaN(len,1);
      for i=1+n:len
        p = this.price(i);
        l = min(this.low(i-n:i));
        h = max(this.high(i-n:i));
        oscFast(i) = Futil.Round(100*((p-l)/(h-l)));
      endfor
      oscFast(isnan(oscFast)) = []; % clean up
      oscSlow = MovingAvg.SMA(oscFast,this.wndLengthSlow);
    endfunction

    function [] = Plot(this)
      figure;
      this.Subplot();
      ## https://stackoverflow.com/questions/67171470/easy-waybuiltin-function-to-put-main-title-in-plot-in-octave
      S = axes('visible','off','title',this.finput.symbol,'FontSize',16);
    endfunction

    function [] = Subplot(this)

      t=this.timestamp;
      [oscSlow,oscFast] = this.CalcSO();

      subplot(2,1,1);
      plot(t(this.numPeriods+1:end),this.price(this.numPeriods+1:end),'--.','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

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
      plot(t(this.numPeriods+1:end),oscFast,'-.','color','blue','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

      hold on;
      plot(t(this.numPeriods+1:end),oscSlow,'-','color',[1,0.5,0],'MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);
      this.AddGuideLines(80,20);

      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      ylabel('Stochastic Oscillator','FontSize',Futil.YLabelFontSize);
      legend('%K','%D');

      grid on;
      grid minor;
      hold off;

    endfunction
  endmethods %Public

  methods (Access = private)
    function [] = AddGuideLines(this,high,low)
      xlim = get(gca(),'xlim');
      n=xlim(2)-xlim(1)+1;
      dx=20;dy=5;

      plot([xlim(1):xlim(2)],ones(1,n)*high,'--','color',[0.5,0.5,0.5],'LineWidth',Futil.PlotLineWidth);
      text(xlim(1)+dx,high+dy,'Overbought > 80');

      plot([xlim(1):xlim(2)],ones(1,n)*low,'--','color',[0.5,0.5,0.5],'LineWidth',Futil.PlotLineWidth);
      text(xlim(1)+dx,low-dy,'Oversold < 20');
    endfunction
  endmethods
endclassdef
