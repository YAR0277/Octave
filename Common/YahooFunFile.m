classdef YahooFunFile < CsvFile
  % To handle fundamental data downloaded from Yahoo finance

  properties
    cfg
    Data
    DataFolder
    DateFormat
    FileName
    fieldsFile
    fields
    Ticker
  endproperties

  methods % Public

    function [obj] = YahooFunFile(varargin)

      baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
      projectsFolder = fullfile(baseFolder,'Projects');
      octaveFolder = fullfile(projectsFolder,'Octave');
      batchFolder = fullfile(projectsFolder,'Batch');

      addpath(fullfile(octaveFolder,'Finance'));

      obj = obj@CsvFile();
      if nargin == 0
        obj.cfg = Config.Instance(fullfile(batchFolder,'config.txt'));
      else
        obj.cfg = varargin(1);
      endif

      obj.fieldsFile = fullfile(batchFolder,'Fields.txt');
      obj.fields = obj.ReadFields;

      obj.Data = struct();
      obj.DataFolder = fullfile(Util.RootDataFolder,'fundamentals');
      obj.DateFormat = 'yyyy-mm-dd';
      obj.FileName = '';
      obj.Ticker = '';
    endfunction

    function [r] = get.DataFolder(this)
      r = this.DataFolder;
    endfunction

    function [] = set.DataFolder(this,dataFolder)
      this.DataFolder = dataFolder;
    endfunction

    function [r] = get.DateFormat(this)
      r = this.DateFormat;
    endfunction

    function [] = set.DateFormat(this,dateFormat)
      this.DateFormat = dateFormat;
    endfunction

    function [r] = get.FileName(this)
      r = this.FileName;
    endfunction

    function [] = set.FileName(this,fileName)
      this.FileName = fileName;
    endfunction

    function [r] = get.Ticker(this)
      if isempty(this.Ticker)
        [~,filename,~] = fileparts(this.FileName);
        r = filename;
      else
        r = this.Ticker;
      endif
    endfunction

    function [] = set.Ticker(this,ticker)
      this.Ticker = ticker;
    endfunction

    function [r] = GetTimestamp(this)
      r = this.Data.lastUpdated;
    endfunction

    function [r] = GetValue(this,name)
      if isfield(this.Data, name)
        r = this.Data.(name);
      else
        error('Field "%s" does not exist.', name);
      end
    endfunction

    function col = GetValueFormatted(this,name)
      % from ChatGPT

      % Get column values first
      raw = this.GetValue(name);

      % Format each element
      col = cell(size(raw));
      for i = 1:length(raw)
          val = raw{i};
          if ischar(val)
              % Try converting string to number
              num = str2double(val);
              if ~isnan(num)
                  col{i} = Util.FormatNumber(num);
              else
                  col{i} = val;  % leave as string
              end
          elseif isnumeric(val)
              col{i} = Util.FormatNumber(val);
          else
              col{i} = val;  % fallback
          end
      end
    endfunction

    function [] = LoadFile(this,fileName)
      this.FileName = fileName;
      fid = fopen(fullfile(this.DataFolder,this.FileName),'r');
      if fid == -1
        error('File (%s) does not exist. \n',this.FileName);
      endif

      % skip the header row
      fgetl(fid);

      % holds data from CSV file
      data = {};

      tline = fgetl(fid);
      row = 1;
      while ischar(tline)
        cols = strsplit(tline, ',');
        data(row, 1:length(cols)) = cols;
        tline = fgetl(fid);
        row = row + 1;
      endwhile

      % fill Data struct with data from CSV file
      nRows = size(data,1);
      % first col 'lastUpdated' is not in Fields.txt, so add it manually
      this.Data.lastUpdated = data(:,1);
      % other columns are taken from Fields.txt
      for i = 1:length(this.fields)
        colIdx = i + 1; % offset by 1 because of lastUpdated
        if colIdx <= size(data,2) % check to see if colIdx points to an index in data
          this.Data.(this.fields{i}) = data(:,colIdx);
        else
          this.Data.(this.fields{i}) = cell(nRows,1); % empty if missing
        endif
      endfor
    endfunction

    function [] = SetFolder(this,type)
      % appends DataFolder with type
      if ismember(type,{"bond","equity","etf","index","intraday","fundamentals"})
        this.DataFolder = fullfile(Util.RootDataFolder,type);
      end
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

  endmethods %Public

  methods (Access = private)

    function [fields] = ReadFields(this)
      fid = fopen(this.fieldsFile, 'r');
      if fid == -1
        error('Cannot open file %s\n',this.fieldsFile);
      endif
      fields = {};
      tline =fgetl(fid);
      while ischar(tline)
        fields{end+1} = strtrim(tline);
        tline = fgetl(fid);
      endwhile
    endfunction

  endmethods %Private
endclassdef
