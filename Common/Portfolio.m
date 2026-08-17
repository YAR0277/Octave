classdef Portfolio

  properties
    BatchFolder
    Data
    DataFolder
    DateFormat
    FileName
  endproperties

  methods % Public

    function [obj] = Portfolio()

      pkg load tablicious;

      baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
      projectsFolder = fullfile(baseFolder,'Projects');
      octaveFolder = fullfile(projectsFolder,'Octave');

      addpath(fullfile(octaveFolder,'Finance'));

      obj.BatchFolder = fullfile(projectsFolder,'Batch');
      obj.DataFolder = fullfile(Util.RootDataFolder,'etf'); % default data folder is etf;
      obj.DateFormat = 'yyyy-mm-dd';
      obj.FileName = fullfile(obj.BatchFolder,'portfolio.csv');
      obj = obj.LoadPortfolio();
    endfunction

    function [num,ror,apr] = CalcReturn(this)
      [num,ror,apr] = this.ReturnsEx.CalcReturn();
    endfunction

    function [] = ShowPortfolio(this)

      timestamp = this.Data.Date;
      tickers = this.Data.Ticker;
      cost = this.Data.Cost;
      equityFlag = this.Data.EquityFlag;

      n = numel(tickers);
      numDays = zeros(n,1);
      ror = zeros(n,1);
      apr = zeros(n,1);

      numDaysBuy = zeros(n,1);
      rorBuy = zeros(n,1);
      aprBuy = zeros(n,1);

      f=YahooFile;

        for i=1:n

          if equityFlag(i)
            f.SetFolder('equity');
          else
            f.SetFolder('etf');
          endif

          try
            ticker = tickers{i};
            filename = strcat(ticker,'-d.csv');
            f.LoadFile(filename);
            r=ReturnsEx(f);
            [numDays(i),ror(i),apr(i)] = r.CalcReturn();

            r.StartDay = timestamp(i);
            [numDaysBuy(i),rorBuy(i),aprBuy(i)] = r.CalcReturn();
          catch ME
            continue;
          end_try_catch
        endfor

      T = table(tickers,...
                numDays,ror,apr,...
                numDaysBuy,rorBuy,aprBuy);
      prettyprint(T);
    endfunction

  endmethods %Public

  methods (Access = private)

    function [this] = LoadPortfolio(this)

      s = struct('Date',0,'Ticker',0,'Cost',0,'EquityFlag',0);

      data=csv2cell(this.FileName);
      firstDataRow=2; % row 1 is for header

      this.Data.Date=datenum(data(firstDataRow:end,1),this.DateFormat);
      this.Data.Ticker = data(firstDataRow:end,2);
      this.Data.Cost = cell2mat(data(firstDataRow:end,3));
      this.Data.EquityFlag = cell2mat(data(firstDataRow:end,4));

    endfunction

  endmethods
endclassdef
