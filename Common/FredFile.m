classdef FredFile < CsvFile
  % Input structure for FRED data

  properties (Constant)
    COL_IDX_OBSERVATION_DATE = 1;
    COL_IDX_VALUE = 2;
  endproperties

  properties
    dataFolder
    dataDefinitionTable
    fileName
    files
    flagRecession
    id
    observationDate
    timestamp
    value
  endproperties

  methods % Public

    function [obj] = FredFile(varargin)

      pkg load tablicious;
      addpath(genpath('../Common')); % for class Constant

      obj = obj@CsvFile();
      obj.dataFolder = '../../../data/fred'; % FRED root data folder;
      % https://search.brave.com/search?q=matlab+list+of+folders+and+files&summary=1&conversation=a7a1afd506077f07a51db2
      myfiles=dir(fullfile(obj.dataFolder,'**','*'));
      obj.files=myfiles(~[myfiles.isdir]);
      obj.dataDefinitionTable = struct2table(obj.files);

      ids = arrayfun(@(f) Util.RemoveFileExt(f), obj.dataDefinitionTable.name,'UniformOutput', false);
      obj.dataDefinitionTable = addvars(obj.dataDefinitionTable,ids,'NewVariableNames',{'ids'});
      obj.flagRecession = 1;

      if nargin == 1
        obj.LoadId(varargin{1});
      endif
    endfunction

    function [] = AddRecession(this,ax,timestamp,hgt)
      recessionClass=FredFile('JHDUSRGDPBR');
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

    function [r] = GetTimestamp(this)
      r = this.timestamp;
    end

    function [r] = GetValue(this)
      r = this.value;
    end

    function [] = LoadId(this,id)
      if ismember(id,this.dataDefinitionTable.ids)
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
      TimeSeries.PlotAggregate(this,dt);
    endfunction

    function [] = PlotAdjusted(this,wlen)
      TimeSeries.PlotAdjusted(this,wlen);
    endfunction

    function [] = PlotTrend(this,wlen)
      TimeSeries.PlotTrend(this,wlen);
    endfunction

    function [] = ShowData(this)
      % shows {ids,category} from data definition table
      ids = arrayfun(@(f) Util.RemoveFileExt(f), this.dataDefinitionTable.name,'UniformOutput', false);
      categories = this.dataDefinitionTable.folder;

      % https://github.com/apjanke/octave-tablicious/blob/main/README.md
      % pkg install https://github.com/apjanke/octave-tablicious/releases/download/v0.4.5/tablicious-0.4.5.tar.gz
      % pkg load tablicious
      T = table(ids,categories);
      % https://wiki.octave.org/Function_tableprint#Usage
      prettyprint(T);
    endfunction

    function [] = Stats(this)
      % calculates statistics
      timestep = Util.GetTimeStep(this.timestamp);
      d1 = datestr(this.timestamp(1));
      d2 = datestr(this.timestamp(end));
      y = this.GetValue;
      n = length(y);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr. Samples: %d\n',d1,d2,timestep,n);
      [v_max,i_max] = max(y);
      [v_min,i_min] = min(y);
      fprintf('Range: [%.2f,%.2f], Mean %.2f\n',v_min,v_max,mean(y(~isnan(y))));
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

      label_str = this.id;
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

      title_str = this.id;
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

    function [] = Load(this)
      fileName = fullfile(this.dataFolder,this.fileName);
      fid = fopen(fileName{:}, 'r');
      fin = textscan(fid,"%s %f", 'Delimiter', ',', 'HeaderLines', 1);
      this.observationDate = cell2mat(fin{FredFile.COL_IDX_OBSERVATION_DATE});
      this.value = fin{FredFile.COL_IDX_VALUE};
    endfunction

    function [] = SetFileName(this,id)
      % sets fileName property
      [~,rix] = ismember(id,this.dataDefinitionTable.ids);
      this.fileName = this.dataDefinitionTable(rix,:).name;
    endfunction

    function [] = SetFolder(this,id)
      % append subfolder category to data folder
      [~,rix] = ismember(id,this.dataDefinitionTable.ids);
      this.dataFolder = this.dataDefinitionTable(rix,:).folder;
    endfunction

    function [] = SetTimestamp(this)
      this.timestamp = datenum(this.observationDate,'yyyy-mm-dd');
    endfunction
  endmethods
endclassdef
