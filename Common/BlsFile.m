classdef BlsFile < CsvFile
  % Input structure for BLS data

  properties (Constant)
    COL_IDX_ID = 1;
    COL_IDX_YEAR = 2;
    COL_IDX_PERIOD = 3;
    COL_IDX_LABEL = 4;
    COL_IDX_VALUE = 5;
  endproperties

  properties
##    fileName
    flagRecession
    label
    period
    year
  endproperties

  methods % Public

    function [obj] = BlsFile(varargin)

##      pkg load tablicious;
      addpath(genpath('../Common')); % for class Constant
      addpath(genpath('../FRED')); % for class Rinput

      obj = obj@CsvFile();
      obj.dataFolder = '../../../data/bls'; % BLS root data folder;
##      obj.SetDataDefinitionTable();
      myfiles=dir(fullfile(obj.dataFolder,'**','*'));
      obj.files=myfiles(~[myfiles.isdir]);
      obj.dataDefinitionTable = struct2table(obj.files);

      ids = arrayfun(@(f) Util.RemoveFileExt(f), obj.dataDefinitionTable.name,'UniformOutput', false);
      obj.dataDefinitionTable = addvars(obj.dataDefinitionTable,ids,'NewVariableNames',{'ids'});
      obj.flagRecession = 0;

      if nargin == 1
        obj.LoadId(varargin{1});
      endif
    endfunction

    function [] = DoPlot(this,t,x)

      figure;
      hold on;
      plot(t,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(t); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x','mmm yy','keepticks','keeplimits');
      xlim([t(1) t(end)]);

      label_str = this.id;
      ylabel(label_str);

      if strcmp(label_str,'thousands') == 1 % set yticklabels
        yticks = get(ax,"YTick");
        ticklabels = arrayfun(@(x) strcat(num2str(x),'k'), yticks/1000, "UniformOutput", false);
        yticklabels(ticklabels);
      endif

      ylimits = ylim;
      if this.flagRecession
        recessionFile = FredFile('JHDUSRGDPBR');
        recessionFile.AddRecession(ax,this.timestamp,ylimits(2));
      endif
      ylim([ylimits(1) ylimits(2)]);

      title_str = this.id;
      title(title_str);
      grid on;
      hold off;
    endfunction

    function [] = Load(this)
      [~,rix] = ismember(this.id,this.dataDefinitionTable.ids);
      fname = this.dataDefinitionTable(rix,:).name;

      this.dataFolder = this.dataDefinitionTable(rix,:).folder;
      fileName = fullfile(this.dataFolder,fname);
      fid = fopen(fileName{:}, 'r');
      fin = textscan(fid,"%s %d %s %s %f", 'Delimiter', ',', 'HeaderLines', 1);
      this.year = fin{BlsFile.COL_IDX_YEAR};
      this.period = cell2mat(fin{BlsFile.COL_IDX_PERIOD});
      this.label = cell2mat(fin{BlsFile.COL_IDX_LABEL});
      this.value = fin{BlsFile.COL_IDX_VALUE};
    endfunction

    function [] = SetTimestamp(this)
      this.timestamp = datenum(this.label,'yyyy mmm');
    endfunction
  endmethods
endclassdef
