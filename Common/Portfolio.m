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
      purchasePrice = this.Data.Price;
      shares = this.Data.Shares;
      equityFlag = this.Data.EquityFlag;

      n = numel(tickers);
      daysData = NaN(n,1);
      rorData = NaN(n,1);
      aprData = NaN(n,1);

      daysHolding = NaN(n,1);
      rorHolding = NaN(n,1);
      aprHolding = NaN(n,1);

      for i=1:n

        f = YahooFile;
        if equityFlag(i)
          f.SetFolder('equity');
        else
          f.SetFolder('etf');
        endif

        try
          ticker = tickers{i};
          filename = strcat(ticker,'-d.csv');
          f.LoadFile(filename);

          r = ReturnsEx(f);
          [daysData(i),rorData(i),aprData(i)] = r.CalcReturn();

          r.StartDay = timestamp(i);
          [daysHolding(i),rorHolding(i),aprHolding(i)] = r.CalcReturn();
        catch ME
          fprintf('Error processing %s: %s\n', ticker, ME.message);
          continue;
        end_try_catch
      endfor

      T = table(tickers,purchasePrice,shares,...
                daysData,rorData,aprData,...
                daysHolding,rorHolding,aprHolding);
      prettyprint(T);
    endfunction

  endmethods %Public

  methods (Access = private)

    function [this] = LoadPortfolio(this)

      s = struct('Date',0,'Ticker',0,'Price',0,'Shares',0,'EquityFlag',0);

      data=csv2cell(this.FileName);
      firstDataRow=2; % row 1 is for header

      this.Data.Date=datenum(data(firstDataRow:end,1),this.DateFormat);
      this.Data.Ticker = data(firstDataRow:end,2);
      this.Data.Price = cell2mat(data(firstDataRow:end,3));
      this.Data.Shares = cell2mat(data(firstDataRow:end,4));
      this.Data.EquityFlag = cell2mat(data(firstDataRow:end,5));

    endfunction

  endmethods
endclassdef
