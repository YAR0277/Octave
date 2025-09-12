classdef Binput < handle
  % Input structure for BLS data

  properties (Constant)
    COL_IDX_ID = 1;
    COL_IDX_CATEGORY = 2;
    COL_IDX_SEASONALITY = 3;
    COL_IDX_UNIT = 4;
    COL_IDX_TITLE = 5;
    ROW_IDX_FIRSTDATA = 2;
  endproperties

  properties
    id
    year
    period
    label
    value
    timestamp
    fileName
    dataFolder
    dataDefinitionTable
  endproperties

  methods % Public

    function [obj] = Binput(id)
      obj.dataFolder = 'c:\users\drdav\data\bls'; % BLS root data folder;
      obj.SetDataDefinitionTable();

      if obj.GetRowIdx(Binput.COL_IDX_ID,id)
        obj.SetFileName(id);
        obj.SetFolder(id);
        obj.Load();
      endif
      obj.SetTimestamp();
    endfunction

    function [] = Plot(this)

      if isempty(this.value)
        fprintf('No data to plot.\n');
        return;
      endif

      figure;
      plot(this.timestamp,this.value,'--.','MarkerSize',Butil.PlotMarkerSize,'LineWidth',Butil.PlotLineWidth);

      [xticks,fmt] = Butil.GetDateTicks(this.timestamp); %this.GetTimeTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x','mmm yy','keepticks','keeplimits');
      xlim([xticks(1) xticks(end)]);

      rowIdx = this.GetRowIdx(Binput.COL_IDX_ID,this.id(1,:));

      label_str = this.dataDefinitionTable(rowIdx,Binput.COL_IDX_UNIT);
      ylabel(label_str,'FontSize',Butil.YLabelFontSize);

      if strcmp(label_str,'thousands') == 1 % set yticklabels
        yticks = get(ax,"YTick");
        ticklabels = arrayfun(@(x) strcat(num2str(x),'k'), yticks/1000, "UniformOutput", false);
        yticklabels(ticklabels);
      endif

      title_str = this.dataDefinitionTable(rowIdx,Binput.COL_IDX_TITLE);
      title(title_str,'FontSize',Butil.TitleFontSize);
      grid on;

    endfunction

    function [] = Stats(this)
      % calculates statistics
      timestep = Butil.GetTimeStep(this.timestamp);
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

    function [r] = GetRowIdx(this,colIdx,val)
      vals = this.dataDefinitionTable(Binput.ROW_IDX_FIRSTDATA:end,colIdx);
      [~,r] = ismember(val,vals);
      r = r + 1; % add 1 for header
    endfunction

    function [] = SetDataDefinitionTable(this)
      this.dataDefinitionTable = {'id','category','seasonality','unit','title'};
      this.dataDefinitionTable(end+1,:)={'APU0000708111', 'inflation',    'not adjusted', 'per dozen',  'Eggs, grade A, large, per doz. in U.S. city average'};
      this.dataDefinitionTable(end+1,:)={'CEU0000000001', 'employment',   'not adjusted', 'thousands',  'All employees, thousands, total nonfarm, not seasonally adjusted'};
      this.dataDefinitionTable(end+1,:)={'CES0000000001', 'employment',   'adjusted',     'thousands',  'All employees, thousands, total nonfarm, seasonally adjusted'};
      this.dataDefinitionTable(end+1,:)={'LNU04000000',   'unemployment', 'not adjusted', 'percent',    'Unemployment Rate'};
      this.dataDefinitionTable(end+1,:)={'LNS14000000',   'unemployment', 'adjusted',     'percent',    'Unemployment Rate'};
    endfunction

    function [] = SetFileName(this,id)
      % sets fileName property
      this.fileName = strcat(id,'.csv');
    endfunction

    function [] = SetFolder(this,id)
      % append subfolder category to data folder
      rowIdx = this.GetRowIdx(Binput.COL_IDX_ID,id);
      subFolder = this.dataDefinitionTable(rowIdx,Binput.COL_IDX_CATEGORY);
      this.dataFolder = fullfile(this.dataFolder,subFolder);
    endfunction

    function [] = SetTimestamp(this)
      this.timestamp = datenum(this.label,'yyyy mmm');
    endfunction

    function [] = Load(this)
      fileName = fullfile(this.dataFolder,this.fileName);
      fid = fopen(fileName{:}, 'r');
      fin = textscan(fid,"%s %d %s %s %f", 'Delimiter', ',', 'HeaderLines', 1);
      this.id = cell2mat(fin{1});
      this.year = fin{2};
      this.period = cell2mat(fin{3});
      this.label = cell2mat(fin{4});
      this.value = fin{5};
    endfunction

  endmethods
endclassdef
