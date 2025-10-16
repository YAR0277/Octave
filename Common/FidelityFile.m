classdef FidelityFile < CsvFile
  % Input structure for financial functions plotf, readf and classes

  properties
    data
    dataCol
    dataFolder
    dateFormat
    descendFlag
    fileName
    symbol
    timestamp
  endproperties

  methods % Public

    function [obj] = FidelityFile()

      addpath(genpath('../Finance')); % for readf

      obj = obj@CsvFile();
      obj.dataCol = 'Close'; % 'Open','High','Low','Close','pctChange','pctChangeAvg','Volume'
      obj.dataFolder = '../../../data/finance'; % financial data folder;
      obj.dateFormat = 'yyyy-mm-dd';
      obj.descendFlag = 0; % data is in ascending order: oldest -> newest
      obj.fileName = '';
      obj.symbol = '';
    endfunction

    function [r] = GetTimestamp(this)
      r = this.data.Date;
    end

    function [r] = GetPctChange(this)
      r = this.data.pctChange;
    end

    function [r] = GetValue(this)
      r = this.data.(this.dataCol);
    end

    function [r] = GetVolume(this)
      r = this.data.Volume;
    end

    function [] = LoadFile(this,fileName)
      this.SetFile(fileName);
      if exist(fullfile(this.dataFolder,this.fileName),'file')
        this.data = readf(this);
      else
        fprintf('file (%s) does not exist. \n',this.fileName);
      endif
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

    function [] = PlotAggregate(this,dt)
      TimeSeries.PlotAggregate(this,dt);
    endfunction

    function [] = PlotTrend(this,wlen)
      TimeSeries.PlotTrend(this,wlen);
    endfunction

    function [] = SetFile(this,fileName)
      % sets fileName property
      this.fileName = fileName;
    endfunction

    function [] = SetFolder(this,type)
      % sets dataFolder property
      if ismember(type,{"bond","equity","etf","index"})
        this.dataFolder = fullfile(this.dataFolder,type);
      end
    endfunction

    function [] = SetSymbol(this,symbol)
      % sets symbol property
      this.symbol = symbol;
    endfunction

    function [] = ShowFiles(this)
      % shows all files in dataFolder
      dir(fullfile(this.dataFolder,'*.csv'))
    endfunction

    function [r] = ShowFolders(this)
      % shows all files in dataFolder
      % https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
      folders=dir(this.dataFolder);
      idx=[folders(:).isdir];
      r = {folders(idx).name}';
      r(ismember(r,{'.','..'})) = [];
    endfunction
  endmethods %Public

  methods (Access = private)

    function [] = DoPlot(this,t,x)
      figure;
      hold on;
      plot(t,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      label_str = "Values";
      ylabel(label_str,'FontSize',Constant.YLabelFontSize);

      ylimits = ylim;
      ylim([ylimits(1) ylimits(2)]);

      title_str = this.fileName;
      title(title_str,'FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction
  endmethods
endclassdef
