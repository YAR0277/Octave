classdef CsvFile < handle
  % No Interfaces in Octave (yet)

  properties
    dataDefinitionTable
    dataFolder
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
      r = this.timestamp;
    endfunction

    function [r] = GetValue(this)
      % [r] = GetValue() returns value.
      r = this.value;
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

    function [] = PlotTrend(this,wlen)
      % [] = PlotTrend(wlen), plots trend with window length, e.g. wlen=12.
      ts = TimeSeries(this);
      ts.PlotTrend(wlen);
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
endclassdef
