classdef CsvFile < handle
  % No Interfaces in Octave (yet)

  properties (Constant)
    BaseFolder = fileparts(fileparts(fileparts(pwd())));
  endproperties

  properties
    dataDefinitionTable
    DataFolder
    files
    id
    timestamp
    value
  endproperties

  methods %Public
    function obj = CsvFile()
      % c'tor to create a CsvFile object, parent object for XXXFile objects.
      pkg load tablicious;
    endfunction

    function [r] = GetTimestamp(this)
      % [r] = GetTimestamp() returns timestamp.
      ix = ~isnan(this.value);
      r = this.timestamp(ix);
    endfunction

    function [r] = GetValue(this)
      % [r] = GetValue() returns value.
      ix = ~isnan(this.value);
      r = this.value(ix);
    endfunction

    function [] = LoadId(this,id)
      % [] = LoadId(id), loads file with id.
      if ismember(id,this.dataDefinitionTable.ids)
        this.id = id;
        this.Load();
        this.SetTimestamp();
      else
        fprintf('id (%s) does not exist in data definition table. \n',id);
      endif
    endfunction

    function [] = Plot(this)
      % [] = Plot, plots data.
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        fprintf('No data to plot.\n');
        return;
      endif
      this.DoPlot(t,x);
    endfunction

    function [] = PlotAdjusted(this,wlen)
      % [] = PlotAdjusted(wlen), plots seasonally adjusted data with window length, e.g. wlen=12.
      ts = TimeSeries(this);
      ts.PlotAdjusted(wlen);
    endfunction

    function [] = PlotAggregate(this,dt)
      % [] = PlotAggregate(dt), plots aggregated data with dt=12, for example.
      ts = TimeSeries(this);
      ts.PlotAggregate(dt);
    endfunction

    function [] = PlotEWMA(this,alpha)
      % [] = PlotEWMA(alpha), plots EWMA on existing plot with smoothing factor alpha, e.g. alpha=0.002.
      t = this.GetTimestamp;
      x = MovingAvg.EWMA(this.GetValue,alpha);
      ax = gca;
      hold on;
      plot(ax,t,x,'--','color',Color.Brown);
      Util.DoDateTicks(ax,t);
      hold off;
    endfunction

    function [] = PlotRandomWalk(this,drift,stdev)
      % [] = PlotRandomWalk(drift,stdev), plots a random walk with drift/stdev on existing plot.
      t = this.GetTimestamp;
      x = this.GetValue;
      n = length(t);
      s = Sinput;
      s.Type = 'RandomWalk';
      s.Initval = x(1);
      s.Drift = drift;
      s.Var = stdev^2;
      s.Length = n;
      r = RndSeq(s);
      ax = gca;
      hold on;
      plot(ax,t,r.GetSample,'--','color',Color.Brown);
      Util.DoDateTicks(ax,t);
      ylim('auto');
      hold off;
    endfunction

    function [] = PlotTrend(this,wlen)
      % [] = PlotTrend(wlen), plots trend with window length, e.g. wlen=12.
      ts = TimeSeries(this);
      ts.PlotTrend(wlen);
    endfunction

    function [] = SetFolder(this,type)
      % appends DataFolder with type
      if ismember(type,{"bond","equity","etf","index"})
        this.DataFolder = fullfile(CsvFile.GetDataFolder,type);
      end
    endfunction

    function [] = ShowData(this)
      % [] = ShowData(), shows {ids,category} from data definition table
      ids = this.dataDefinitionTable.ids;
      categories = this.dataDefinitionTable.folder;

      % https://github.com/apjanke/octave-tablicious/blob/main/README.md
      % pkg install https://github.com/apjanke/octave-tablicious/releases/download/v0.4.5/tablicious-0.4.5.tar.gz
      % pkg load tablicious
      T = table(ids,categories);
      % https://wiki.octave.org/Function_tableprint#Usage
      prettyprint(T);
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

    function [] = Stats(this)
      % [] = Stats(), calculates statistics
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

  methods (Static)
    function [r] = GetDataFolder()
      r = fullfile(CsvFile.BaseFolder,"data/finance");
    endfunction
  endmethods
endclassdef
