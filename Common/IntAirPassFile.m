classdef IntAirPassFile < CsvFile
  % Input structure for International Airline Passengers data
  % https://github.com/kartikdube/Datasets/blob/master/international-airline-passengers.csv

  properties (Constant)
    COL_IDX_YEAR = 1;
    COL_IDX_MONTH = 2;
    COL_IDX_PASSENGERS = 3;
    ROW_IDX_FIRSTDATA = 2;
  endproperties

  properties
    fileName
    month
    timestamp
    value
    year
  endproperties

  methods % Public

    function [obj] = IntAirPassFile()

      addpath(genpath('../Common')); % for class Constant

      obj = obj@CsvFile();
    endfunction

    function [r] = GetTimestamp(this)
      r = this.timestamp;
    end

    function [r] = GetValue(this)
      r = this.value;
    end

    function [] = LoadFile(this,fileName)
      this.SetFile(fileName);
      if exist(fullfile(this.DataFolder,this.fileName),'file')
        fid = fopen(fullfile(this.DataFolder,this.fileName), 'r');
        fin = textscan(fid,"%d,%s,%d", 'Delimiter', ',', 'HeaderLines', 1);
        this.year = fin{IntAirPassFile.COL_IDX_YEAR};
        this.month = cell2mat(fin{IntAirPassFile.COL_IDX_MONTH});
        this.value = fin{IntAirPassFile.COL_IDX_PASSENGERS};
        this.SetTimestamp;
      else
        fprintf('file (%s) does not exist. \n',this.fileName);
      endif
    endfunction

    function [] = Plot(this)
      % [] = Plot
      t = this.timestamp;
      x = this.value;
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

    function [] = Stats(this)
      % calculates statistics
      timestep = Util.GetTimeStep(this.timestamp);
      d1 = datestr(this.timestamp(1));
      d2 = datestr(this.timestamp(end));
      y = this.value;
      n = length(y);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr. Samples: %d\n',d1,d2,timestep,n);
      [v_max,i_max] = max(y);
      [v_min,i_min] = min(y);
      fprintf('Range: [%.2f,%.2f], Mean %.2f\n',v_min,v_max,mean(y));
      fprintf('Min: %s, %.2f\n',datestr(this.timestamp(i_min),'mmm yyyy'),v_min);
      fprintf('Max: %s, %.2f\n',datestr(this.timestamp(i_max),'mmm yyyy'),v_max);
    endfunction
  endmethods

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

      ylabel('Passengers (thousands)','FontSize',Constant.YLabelFontSize);
      ylimits = ylim;
      ylim([ylimits(1) ylimits(2)]);

      title('International Airline Passengers','FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction

    function [] = SetTimestamp(this)
      this.timestamp = datenum(strcat(num2str(this.year),strcat('-',this.month)),'yyyy-mmm');
    endfunction
  endmethods

  methods (Static)
    function [r] = GetDataFolder()
      r = fullfile(CsvFile.BaseFolder,"data/sandbox");
    endfunction
  endmethods
endclassdef
