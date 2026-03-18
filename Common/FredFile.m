classdef FredFile < CsvFile
  % Input structure for FRED data

  properties (Constant)
    COL_IDX_OBSERVATION_DATE = 1;
    COL_IDX_VALUE = 2;
  endproperties

  properties
    flagRecession
    observationDate
  endproperties

  methods % Public

    function [obj] = FredFile(varargin)

      addpath(genpath('../Common')); % for class Constant

      obj = obj@CsvFile();
      obj.dataFolder = '../../../data/fred'; % FRED root data folder;
      % https://search.brave.com/search?q=matlab+list+of+folders+and+files&summary=1&conversation=a7a1afd506077f07a51db2
      myfiles=dir(fullfile(obj.dataFolder,'**','*'));
      obj.files=myfiles(~[myfiles.isdir]);
      obj.dataDefinitionTable = struct2table(obj.files);
      % add 'ids' column to table
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

    function [] = DoPlot(this,t,x)
      figure;
      hold on;
      plot(t,x,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

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

    function [] = Load(this)
      [~,rix] = ismember(this.id,this.dataDefinitionTable.ids);
      fname = this.dataDefinitionTable(rix,:).name;

      this.dataFolder = this.dataDefinitionTable(rix,:).folder;
      fileName = fullfile(this.dataFolder,fname);
      fid = fopen(fileName{:}, 'r');
      fin = textscan(fid,"%s %f", 'Delimiter', ',', 'HeaderLines', 1);
      this.observationDate = cell2mat(fin{FredFile.COL_IDX_OBSERVATION_DATE});
      this.value = fin{FredFile.COL_IDX_VALUE};
    endfunction

    function [] = SetTimestamp(this)
      this.timestamp = datenum(this.observationDate,'yyyy-mm-dd');
    endfunction
  endmethods

  methods (Access = private)
    function [ia,ib,lengths] = GetOnes(this)
      x = this.value;
      t = this.timestamp;
      ia = find(diff([0;x]) == 1);  % start indices
      ib = find(diff([x;0]) == -1); % end indices
      lengths = t(ib) - t(ia);
    endfunction
  endmethods
endclassdef
