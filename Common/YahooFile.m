classdef YahooFile < CsvFile
  % Duplicate of FidelityFile

  properties
    cfg
    Data
    DataCol
    DataFolder
    DateFormat
    DescendFlag
    FileName
    BB
    MACD
    PriceEx
    ReturnsEx
    RSI
    Ticker
  endproperties

  methods % Public

    function [obj] = YahooFile(varargin)

      baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
      projectsFolder = fullfile(baseFolder,'Projects');
      octaveFolder = fullfile(projectsFolder,'Octave');
      batchFolder = fullfile(projectsFolder,'Batch');

      addpath(fullfile(octaveFolder,'Finance'));

      obj = obj@CsvFile();
      if nargin == 0
        obj.cfg = Config.Instance(fullfile(batchFolder,'config.txt'));
      else
        obj.cfg = varargin(1);
      endif

      obj.DataCol = 'Close'; % 'Open','High','Low','Close','Volume'
      obj.DataFolder = fullfile(Util.RootDataFolder,'etf'); % default data folder is etf;
      obj.DateFormat = 'yyyy-mm-dd';
      obj.DescendFlag = 0; % data is in ascending order: oldest -> newest
      obj.FileName = '';
      obj.Ticker = '';
      obj.BB = BBEx(obj); # has-a
      obj.MACD = MACDEx(obj); # has-a
      obj.PriceEx = PriceEx(obj); # has-a
      obj.ReturnsEx = ReturnsEx(obj); # has-a
      obj.RSI = RSIEx(obj); # has-a
    endfunction

    function [r] = get.DataCol(this)
      r = this.DataCol;
    endfunction

    function [] = set.DataCol(this,dataCol)
      this.DataCol = dataCol;
    endfunction

    function [r] = get.DataFolder(this)
      r = this.DataFolder;
    endfunction

    function [] = set.DataFolder(this,dataFolder)
      this.DataFolder = dataFolder;
    endfunction

    function [r] = get.DateFormat(this)
      r = this.DateFormat;
    endfunction

    function [] = set.DateFormat(this,dateFormat)
      this.DateFormat = dateFormat;
    endfunction

    function [r] = get.DescendFlag(this)
      r = this.DescendFlag;
    endfunction

    function [] = set.DescendFlag(this,descendFlag)
      this.DescendFlag = descendFlag;
    endfunction

    function [r] = get.FileName(this)
      r = this.FileName;
    endfunction

    function [] = set.FileName(this,fileName)
      this.FileName = fileName;
    endfunction

    function [r] = get.Ticker(this)
      if isempty(this.Ticker)
        [~,filename,~] = fileparts(this.FileName);
        r = regexprep(filename,'-[deiw]$', '');
      else
        r = this.Ticker;
      endif
    endfunction

    function [] = set.Ticker(this,ticker)
      this.Ticker = ticker;
    endfunction

    function [num,ror,apr] = CalcReturn(this)
      [num,ror,apr] = this.ReturnsEx.CalcReturn();
    endfunction

    function [lt0,gt0] = GetIQM(this,x)
      [lt0,gt0] = this.PriceEx.GetIQM(x);
    endfunction

    function [ltm,utm] = GetTailMeans(this,x)
      [ltm,utm] = this.PriceEx.GetTailMeans(x);
    endfunction

    function [r] = GetPrices(this)
      r = this.PriceEx.GetPrices;
    endfunction

    function [r] = GetClose(this)
      r = this.Data.('Close');
    end

    function [r] = GetOpen(this)
      r = this.Data.('Open');
    end

    function [r] = GetHigh(this)
      r = this.Data.('High');
    end

    function [r] = GetLow(this)
      r = this.Data.('Low');
    end

    function [r] = GetTimestamp(this)
      r = this.Data.Date;
    end

    function [r] = GetValue(this)

      cfg = Config.Instance();
      priceType = cfg.get('PriceType');

      switch priceType
        case "high"
          this.DataCol = 'High';
        case "low"
          this.DataCol = 'Low';
        case "open"
          this.DataCol = 'Open';
        otherwise
          this.DataCol = 'Close';
      endswitch

      r = this.Data.(this.DataCol);
    end

    function [r] = GetVolume(this)
      r = this.Data.Volume;
    end

    function [] = LoadFile(this,fileName)
      this.FileName = fileName;
      if exist(fullfile(this.DataFolder,this.FileName),'file')
        this.Data = readf(this);
      else
        fprintf('file (%s) does not exist. \n',this.FileName);
      endif
    endfunction

    function [] = Plot(this)
      % [] = Plot
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        error('No data to plot.');
      endif
      this.DoPlot(t,x);
    endfunction

    function [] = PlotAggregate(this,dt)
      TimeSeries.PlotAggregate(this,dt);
    endfunction

    function [] = PlotTrend(this,wlen)
      TimeSeries.PlotTrend(this,wlen);
    endfunction

    function [] = PlotBB(this)
      this.BB.Plot;
    endfunction

    function [] = PlotMACD(this)
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        error('No data to plot.');
      endif
      this.MACD.Plot(t,x);
    endfunction

    function [] = PlotSMA(this)
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        error('No data to plot.');
      endif
      this.PriceEx.PlotSMA(t,x);
    endfunction

    function [] = PlotEMA(this)
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        error('No data to plot.');
      endif
      this.PriceEx.PlotEMA(t,x);
    endfunction

    function [r] = PlotMM(this,varargin)
      [r] = this.PriceEx.PlotMM(varargin);
    endfunction

    function [] = PlotRSI(this)
      this.RSI.Plot;
    endfunction

    function [] = PlotOO(this)
      % PlotOO stands for plot on/off market:
      % on = NYSE market hours, off = after hrs + pre-market
      ts = this.GetTimestamp;
      open = this.GetOpen;
      close = this.GetClose;
      t = ts(2:end);
      doff = open(2:end)-close(1:end-1); % off market diffs
      don = close(2:end)-open(2:end); % on market diffs

      figure;
      hold on;

      for i = 1:length(t)
        plot([t(i) t(i)],[don(i) doff(i)],'k');

        if don(i) >= 0 && doff(i) >= 0
          rectangle('Position', [t(i)-0.3, 0, 0.6, don(i)], ...
            'FaceColor', Color.LightGrey, 'EdgeColor', 'k');
          rectangle('Position', [t(i)-0.3, don(i), 0.6, don(i)+doff(i)], ...
            'FaceColor', Color.Maroon, 'EdgeColor', 'k');
        elseif don(i) < 0 && doff(i) < 0
          rectangle('Position', [t(i)-0.3, don(i), 0.6, -don(i)], ...
            'FaceColor', Color.LightGrey, 'EdgeColor', 'k');
          rectangle('Position', [t(i)-0.3, don(i)+doff(i), 0.6, -doff(i)], ...
            'FaceColor', Color.Maroon, 'EdgeColor', 'k');
        elseif don(i) < 0 && doff(i) >= 0
          rectangle('Position', [t(i)-0.3, don(i), 0.6, -don(i)], ...
            'FaceColor', Color.LightGrey, 'EdgeColor', 'k');
          rectangle('Position', [t(i)-0.3, 0, 0.6, doff(i)], ...
            'FaceColor', Color.Maroon, 'EdgeColor', 'k');
        elseif don(i) >= 0 && doff(i) < 0
          rectangle('Position', [t(i)-0.3, 0, 0.6, don(i)], ...
            'FaceColor', Color.LightGrey, 'EdgeColor', 'k');
          rectangle('Position', [t(i)-0.3, doff(i), 0.6, -doff(i)], ...
            'FaceColor', Color.Maroon, 'EdgeColor', 'k');
        endif
      endfor

      % add watermark
      text(gca,0.5,0.98,this.Ticker,'units', 'normalized', 'fontsize', 50, ...
           'color', Color.LightGrey, 'horizontalalignment', 'center', 'verticalalignment', 'top');

      plot(t,don,'k--');

      [xticks,fmt] = Util.GetDateTicks(t);
      set(gca,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      label_str = "Price Differences";
      ylabel(label_str,'FontSize',Constant.YLabelFontSize);

      ylimits = ylim;
      ylim([ylimits(1) ylimits(2)]);

      grid on;
      grid minor;
      hold off;

      fprintf('Total price changes -  on hours (%.2f)\n', sum(don(don>0)) - sum(don(don<0)) );
      fprintf('Total price changes - off hours (%.2f)\n', sum(doff(doff>0)) - sum(doff(doff<0)) );
    endfunction

    function [] = SetFolder(this,type)
      % appends DataFolder with type
      if ismember(type,{"bond","equity","etf","index","intraday"})
        this.DataFolder = fullfile(Util.RootDataFolder,type);
      end
    endfunction

    function [] = ShowFiles(this)
      % shows all files in DataFolder
      files = dir(fullfile(this.DataFolder,'*.csv'));
      for k=1:length(files)
        if ~files(k).isdir
          fprintf('%-30s %10d bytes   %s\n', files(k).name, files(k).bytes, files(k).date);
        endif
      endfor
    endfunction

    function [] = ShowMomentum(this)
      t = this.GetTimestamp;
      x = this.GetValue;
      dx = diff(x);

      [signal,macd,~,~] = this.MACD.CalcMACD(x);
      vel = macd;
      acc = macd-signal;

      cfg = Config.Instance();
      momLen = cfg.get('MomentumLength');
      n = min(momLen,length(x)); % consider last MomentumLength values
      [vals,coeffs] = Util.GetSignal(t(end-n+1:end),x(end-n+1:end));

      fmt = [...
            'Nr. Samples (%d), '...
            'Last Date (%s), '...
            'Last Price (%.2f), '...
            'Last Price Change (%.2f)\n'...
            ];
      fprintf(fmt,length(x),Util.GetDatestr(t(end)),x(end),dx(end));

      fmt = [...
            'Price range ([%.2f,%.2f]), '...
            'Median price (%.2f), '...
            'Midrange price (%.2f)\n'...
            ];
      fprintf(fmt,min(this.GetLow),max(this.GetHigh),median(x),(min(x)+max(x))/2);

      fprintf('Slope of signal (last %d) = %.2f\n',momLen,coeffs(1));
      fprintf('Velocity (last %d):\t',momLen);
      fprintf('%10.2f ',vel(end-n+1:end));
      fprintf('\n');
      fprintf('Acceleration (last %d):\t',momLen);
      fprintf('%10.2f ',acc(end-n+1:end));
      fprintf('\n');
    endfunction

    function [r] = TestEMA(this)
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        error('No data to test.');
      endif
      r = this.PriceEx.TestEMA(t,x);
    endfunction

    function [r,buyLineExtrap,m] = WhatToBuyBatch(this,varargin)
      [r,buyLineExtrap,m] = this.PriceEx.WhatToBuyBatch(varargin);
    endfunction

  endmethods %Public

  methods (Access = private)

    function [] = DoPlot(this,t,x)

      plot(t,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      hold on;
      Util.AddWatermark(gca,this.Ticker);

      [xticks,fmt] = Util.GetDateTicks(t);
      set(gca,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      ylimits = ylim;
      ylim([ylimits(1) ylimits(2)]);

      grid on;
      grid minor;
      hold off;
    endfunction
  endmethods
endclassdef
