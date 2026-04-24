classdef IntradayFile < YahooFile
  % Handles intraday data in YahooFile

  methods % Public

    function [obj] = IntradayFile()

      addpath(genpath('../Finance')); % for readf

      obj = obj@YahooFile();
      obj.DataFolder = fullfile(Util.RootDataFolder,'intraday');
      obj.DateFormat = 'yyyy-mm-dd HH:MM:SS';
      obj.MACD = MACDIday(obj); # has-a
    endfunction

    function [] = Plot(this)
      % [] = Plot
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        fprintf('No data to plot.\n');
        return;
      endif
      this.DoPlot(t,x);
    endfunction

    function [] = ShowMACD(this)
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        error('No data to plot.');
      endif
      this.MACD.Plot(t,x);
    endfunction
  endmethods %Public

  methods (Access = private)

    function [] = DoPlot(this,t,x)
      figure;
      hold on;
      tod = (t-floor(t))*86400; % time of day is seconds since midnight
      plot(tod,x,'--.','Color',Color.LightGrey);

      Util.AddWatermark(gca,this.Ticker);

      m = MovingAvg.CMA(x,6); % trend, 6*5min = 30min
      plot(tod,m,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      xt = get(gca, 'xtick');
      labels = arrayfun(@(x) sprintf('%02d:%02d', ...
                      floor(x/3600),floor(mod(x,3600)/60)), ...
                      xt, 'UniformOutput', false);
      set(gca, 'xticklabel', labels);

##      title_str = this.FileName;
##      title(title_str,'FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction
  endmethods
endclassdef
