classdef NoaaFile < CsvFile
  % Input structure for NOAA data

  properties (Constant)
    COL_IDX_OBSERVATION_DATE = 1;
    COL_IDX_VALUE = 2;
  endproperties

  properties
    observationDate
  endproperties

  methods % Public

    function [obj] = NoaaFile(varargin)

      addpath(genpath('../Common')); % for class Constant

      obj = obj@CsvFile();
      obj.dataFolder = '../../../data/noaa'; % NOAA root data folder;

      myfiles=dir(fullfile(obj.dataFolder,'**','*'));
      obj.files=myfiles(~[myfiles.isdir]);
      obj.dataDefinitionTable = struct2table(obj.files);

      ids = arrayfun(@(f) Util.RemoveFileExt(f), obj.dataDefinitionTable.name,'UniformOutput', false);
      obj.dataDefinitionTable = addvars(obj.dataDefinitionTable,ids,'NewVariableNames',{'ids'});

      if nargin == 1
        obj.LoadId(varargin{1});
      endif
    endfunction

    function [] = DoPlot(this,t,x)
      figure;
      hold on;
      plot(t,x,'-','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      label_str = this.id;
      ylabel(label_str,'FontSize',Constant.YLabelFontSize);

      if strcmp(label_str,'thousands') == 1 % set yticklabels
        yticks = get(ax,"YTick");
        ticklabels = arrayfun(@(x) strcat(num2str(x),'k'), yticks/1000, "UniformOutput", false);
        yticklabels(ticklabels);
      endif

      ylimits = ylim;
      ylim([ylimits(1) ylimits(2)]);

      title_str = this.id;
      title(title_str,'FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction

    function [] = Load(this)
      [~,rix] = ismember(this.id,this.dataDefinitionTable.ids);
      fname = this.dataDefinitionTable(rix,:).name;

      this.dataFolder = this.dataDefinitionTable(rix,:).folder;
      fileName = fullfile(this.dataFolder,fname);
      fid = fopen(fileName{:}, 'r');
      fin = textscan(fid,"%s %f", 'Delimiter', ',', 'HeaderLines', 1);
      this.observationDate = cell2mat(fin{NoaaFile.COL_IDX_OBSERVATION_DATE});
      this.value = fin{NoaaFile.COL_IDX_VALUE};
    endfunction

    function [] = SetTimestamp(this)
      this.timestamp = datenum(this.observationDate,'yyyy');
    endfunction
  endmethods
endclassdef
