classdef Rinput < handle
  % Input structure for FRED data

  properties (Constant)
    COL_IDX_OBSERVATION_DATE = 1;
    COL_IDX_VALUE = 2;
    COL_IDX_ID = 1;
    COL_IDX_CATEGORY = 2;
    COL_IDX_SEASONALITY = 3;
    COL_IDX_UNIT = 4;
    COL_IDX_TITLE = 5;
    ROW_IDX_FIRSTDATA = 2;
  endproperties

  properties
    dataFolder
    dataDefinitionTable
    fileName
    flagRecession
    id
    observationDate
    timestamp
    value
  endproperties

  methods % Public

    function [obj] = Rinput(varargin)

      pkg load tablicious;
      addpath(genpath('../Common')); % for class Constant

      obj.dataFolder = '../../../data/fred'; % FRED root data folder;
      obj.SetDataDefinitionTable();
      obj.flagRecession = 1;

      if nargin == 1
        obj.LoadId(varargin{1});
      endif
    endfunction

    function [] = AddRecession(this,ax,timestamp,hgt)
      recessionClass=Rinput('JHDUSRGDPBR');
      recessionTimeStamp = recessionClass.timestamp;
      found = 0;

      [ia,ib,lengths] = recessionClass.GetOnes();
      for i=1:length(ia)
        if ( recessionTimeStamp(ia(i)) >= timestamp(1) && recessionTimeStamp(ia(i)) < timestamp(end) )
          rectangle(ax,'Position',[recessionTimeStamp(ia(i)) 0 lengths(i) hgt],'FaceColor',Color.LightGrey, 'EdgeColor',Color.LightGrey);
          found = 1;
        endif
      endfor

      if ~found
        return; % no recession rectangles -> no annotations
      endif

      this.AddAnnotation(timestamp);
    endfunction

    function [] = AddAnnotation(this,timestamp)
      numYears = uint16((timestamp(end)-timestamp(1))/365);
      arrowStart=0.235;
      arrowLen=.05;
      if numYears > 10
        annotation("textarrow",[0.44 0.487],[0.8 0.8],"string","Recession","fontsize",12,"headstyle","plain","headlength",8,"headwidth",8);
      elseif numYears > 5
        annotation("textarrow",[0.4 0.47],[0.8 0.8],"string","Recession","fontsize",12,"headstyle","plain","headlength",8,"headwidth",8);
      elseif numYears > 1 % dummy - no recesions < 5 years
        annotation("textarrow",[arrowStart arrowStart+arrowLen],[0.8 0.8],"string","Recession","fontsize",12,"headstyle","plain","headlength",8,"headwidth",8);
      else % dummy - no recessions < 1 year
        annotation("textarrow",[0.4 0.47],[0.8 0.8],"string","Recession","fontsize",12,"headstyle","plain","headlength",8,"headwidth",8);
      endif
    endfunction

    function [] = LoadId(this,id)
      if this.GetRowIdx(Rinput.COL_IDX_ID,id)
        this.id = id;
        this.SetFileName(id);
        this.SetFolder(id);
        this.Load();
        this.SetTimestamp();
      else
        fprintf('id (%s) does not exist in data definition table. \n',id);
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
      % [] = PlotAggregate(dt) where dt=12, for example.
      [t,x] = Util.Aggregate(this.timestamp,this.value,dt);
      if isempty(x)
        fprintf('No data to plot.\n');
        return;
      endif
      this.DoPlot(t,x);
    endfunction

    function [] = ShowData(this)
      % shows {id,category,title} from data definition table
      ids = this.dataDefinitionTable(2:end,Rinput.COL_IDX_ID);
      categories = this.dataDefinitionTable(2:end,Rinput.COL_IDX_CATEGORY);
      titles = this.dataDefinitionTable(2:end,Rinput.COL_IDX_TITLE);

      % https://github.com/apjanke/octave-tablicious/blob/main/README.md
      % pkg install https://github.com/apjanke/octave-tablicious/releases/download/v0.4.5/tablicious-0.4.5.tar.gz
      % pkg load tablicious
      T = table(ids,categories,titles);
      % https://wiki.octave.org/Function_tableprint#Usage
      prettyprint(T);
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
      plot(t,x,'-','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      [xticks,fmt] = Util.GetDateTicks(t);
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');
      xlim([t(1) t(end)]);

      rowIdx = this.GetRowIdx(Rinput.COL_IDX_ID,this.id(1,:));
      label_str = this.dataDefinitionTable(rowIdx,Rinput.COL_IDX_UNIT);
      ylabel(label_str,'FontSize',Constant.YLabelFontSize);

      if strcmp(label_str,'thousands') == 1 % set yticklabels
        yticks = get(ax,"YTick");
        ticklabels = arrayfun(@(x) strcat(num2str(x),'k'), yticks/1000, "UniformOutput", false);
        yticklabels(ticklabels);
      endif

      ylimits = ylim;
      if this.flagRecession
        this.AddRecession(ax,t,ylimits(2));
      endif
      ylim([ylimits(1) ylimits(2)]);

      title_str = this.dataDefinitionTable(rowIdx,Rinput.COL_IDX_TITLE);
      title(title_str,'FontSize',Constant.TitleFontSize);
      grid on;
      hold off;
    endfunction

    function [ia,ib,lengths] = GetOnes(this)
      x = this.value;
      t = this.timestamp;
      ia = find(diff([0;x]) == 1);  % start indices
      ib = find(diff([x;0]) == -1); % end indices
      lengths = t(ib) - t(ia);
    endfunction

    function [r] = GetRowIdx(this,colIdx,val)
      vals = this.dataDefinitionTable(Rinput.ROW_IDX_FIRSTDATA:end,colIdx);
      [~,r] = ismember(val,vals);
      r = r + 1; % add 1 for header
    endfunction

    function [] = Load(this)
      fileName = fullfile(this.dataFolder,this.fileName);
      fid = fopen(fileName{:}, 'r');
      fin = textscan(fid,"%s %f", 'Delimiter', ',', 'HeaderLines', 1);
      this.observationDate = cell2mat(fin{Rinput.COL_IDX_OBSERVATION_DATE});
      this.value = fin{Rinput.COL_IDX_VALUE};
    endfunction

    function [] = SetDataDefinitionTable(this)
      this.dataDefinitionTable = {'id','category','seasonality','unit','title'};
      this.dataDefinitionTable(end+1,:)={'LNS13023570','employment','adjusted','Percent','New Entrants as a Percent of Total Unemployed'};
      this.dataDefinitionTable(end+1,:)={'LNU03000002','employment','not adjusted','Thousands','Unemployed Women'};
      this.dataDefinitionTable(end+1,:)={'APU0000708111','prices','not adjusted','U.S. Dollars','Average Price: Eggs, Grade A, Large (per dozen) in U.S. City'};
      this.dataDefinitionTable(end+1,:)={'CPIUFDNS','prices','not adjusted','Index 1982-1984=100','Food in U.S. City Average'};
      this.dataDefinitionTable(end+1,:)={'JHDUSRGDPBR','production','N/A','N/A','Dates of U.S. recessions as inferred by GDP-based recession indicator'};
      this.dataDefinitionTable(end+1,:)={'UEMP27OV','unemployment','adjusted','Thousands of Persons','Long-term unemployment'};
      this.dataDefinitionTable(end+1,:)={'MEUR','unemployment','adjusted','Percent','Unemployment Rate in Maine'};
      this.dataDefinitionTable(end+1,:)={'MEURN','unemployment','not adjusted','Percent','Unemployment Rate in Maine'};
    endfunction

    function [] = SetFileName(this,id)
      % sets fileName property
      this.fileName = strcat(id,'.csv');
    endfunction

    function [] = SetFolder(this,id)
      % append subfolder category to data folder
      rowIdx = this.GetRowIdx(Rinput.COL_IDX_ID,id);
      subFolder = this.dataDefinitionTable(rowIdx,Rinput.COL_IDX_CATEGORY);
      this.dataFolder = fullfile(this.dataFolder,subFolder);
    endfunction

    function [] = SetTimestamp(this)
      this.timestamp = datenum(this.observationDate,'yyyy-mm-dd');
    endfunction
  endmethods
endclassdef
