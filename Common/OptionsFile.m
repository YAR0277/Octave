classdef OptionsFile < CsvFile
  % To handle options data downloaded from Yahoo finance

  properties
    cfg
    Data
    DataFolder
    DataNormalized
    DateFormat
    FileName
    fields
    OptionsTable
    Ticker
  endproperties

  methods % Public

    function [obj] = OptionsFile(varargin)

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

      obj.fields = {'contractSymbol',...
                    'lastTradeDate',...
                    'strike',...
                    'lastPrice',...
                    'bid',...
                    'ask',...
                    'change',...
                    'percentChange',...
                    'volume',...
                    'openInterest',...
                    'impliedVolatility',...
                    'inTheMoney',...
                    'contractSize',...
                    'currency',...
                    'expiration',...
                    'optionType',...
                    'downloadDate'};
      obj.Data = struct();
      obj.DataFolder = fullfile(Util.RootDataFolder,'options');
      obj.DateFormat = 'yyyy-mm-dd HH:MM:SS';
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
        r = regexprep(filename,'-[o]$', '');
      else
        r = this.Ticker;
      endif
    endfunction

    function [] = set.Ticker(this,ticker)
      this.Ticker = ticker;
    endfunction

    function [tbl] = GetOptionsByType(this,optionType)
      idx = strcmpi(this.OptionsTable.optionType, optionType);
      tbl = this.OptionsTable(idx,:);
    endfunction

    function [tbl] = GetExpiration(~,T,expiry)
      idx = T.expiration == expiry;
      tbl = T(idx,:);
    endfunction

    function [tbl] = GetStrike(~,T,S,type)
    % get ITM strike prices
      cfg = Config.Instance();
      n = cfg.get('NumStrikePrices');

      if strcmpi(type,'call')

        % largest strike price less than S
        K0 = max(T.strike(T.strike < S));

        % ITM for call options, K > S
        idx = T.strike >= K0 & T.strike < K0 + n*2.50;

      elseif strcmpi(type,'put')

        % smallest strike price greater than S
        K0 = min(T.strike(T.strike > S));

        % ITM for put options, K < S
        idx = T.strike <= K0 & T.strike >= K0 - n*2.50;

      else
        error('incorrect option type %s',type);
      end

      tbl = T(idx,:);
    endfunction

##    function [r] = GetFundamentalsLast(this)
##      s = this.GetFundamentals;
##      f = @(x) x(end);
##      r = Util.ApplyToStructFields(s,f);
##    endfunction

##    function [r] = GetFundamentalsMean(this)
##      s = this.GetFundamentals;
##      f = @mean;
##      r = Util.ApplyToStructFields(s,f);
##    endfunction

    function [r] = GetTimestamp(this)
      r = this.Data.downloadDate;
    endfunction

    function [r] = GetValue(this,name)
      if isfield(this.Data, name)
        r = this.Data.(name);
      else
        r = 0;
      endif
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
        cols = strsplit(tline, ',', "collapsedelimiters", false); % preserves empty fields in csv file
        data(row, 1:length(cols)) = cols;
        tline = fgetl(fid);
        row = row + 1;
      endwhile

      % fill Data struct with data from CSV file
      nRows = size(data,1);
      % columns are taken from fields
      for i = 1:length(this.fields)
        if i <= size(data,2) % check to see if i points to an index in data
          this.Data.(this.fields{i}) = data(:,i);
        else
          this.Data.(this.fields{i}) = cell(nRows,1); % empty if missing
        endif
      endfor

      this.DataNormalized = this.NormalizeTypes(this.Data);
      this.OptionsTable = struct2table(this.DataNormalized);
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

    function [S] = NormalizeTypes(this,S)

      S.strike              = str2double(S.strike);
      S.lastPrice           = str2double(S.lastPrice);
      S.bid                 = str2double(S.bid);
      S.ask                 = str2double(S.ask);
      S.change              = str2double(S.change);
      S.percentChange       = str2double(S.percentChange);
      S.volume              = str2double(S.volume);
      S.openInterest        = str2double(S.openInterest);
      S.impliedVolatility   = str2double(S.impliedVolatility);

      S.inTheMoney = strcmpi(S.inTheMoney,"TRUE");

      S.expiration  = datenum(S.expiration,'yyyy-mm-dd');
      S.downloadDate = datenum(S.downloadDate,'yyyy-mm-dd');

      % Convert lastTradeDate here as appropriate for its format.
      S.lastTradeDate = this.ToDateTime(S.lastTradeDate);
    endfunction

    function d = ToDateTime(~,timestamp)
      % Yahoo uses an ISO-8601 timestamp with UTC offset: 2026-06-10 13:37:26+00:00
      % datenum does not understand the +00:00 suffix so strip it off before converting.

        % Remove timezone (+00:00)
        timestamp = regexprep(timestamp, '\+\d\d:\d\d$', '');
        % Convert to datenum
        d = datenum(timestamp, 'yyyy-mm-dd HH:MM:SS');
    endfunction

  endmethods %Private
endclassdef
