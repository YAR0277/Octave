classdef FidelityFile < CsvFile
  % Input structure for financial functions plotf, readf and classes

  properties
    Data
    DataCol
    DateFormat
    DescendFlag
    FileName
    Symbol
  endproperties

  methods % Public

    function [obj] = FidelityFile()

      addpath(genpath('../Finance')); % for readf

      obj = obj@CsvFile();
      obj.DataCol = 'Close'; % 'Open','High','Low','Close','Volume'
      obj.DateFormat = 'yyyy-mm-dd';
      obj.DescendFlag = 0; % data is in ascending order: oldest -> newest
      obj.FileName = '';
      obj.Symbol = '';
    endfunction

    function [r] = get.DataCol(this)
      r = this.DataCol;
    endfunction

    function [] = set.DataCol(this,dataCol)
      this.DataCol = dataCol;
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

    function [r] = get.Symbol(this)
      r = this.Symbol;
    endfunction

    function [] = set.Symbol(this,symbol)
      this.Symbol = symbol;
    endfunction

    function [r] = GetTimestamp(this)
      r = this.Data.Date;
    end

    function [r] = GetValue(this)
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

      title_str = this.FileName;
      title(title_str,'FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction
  endmethods
endclassdef
