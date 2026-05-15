function [] = DoWhatToBuyBatch(fid,f,tickernames,cfg,equityFlag)
  n = numel(tickernames);
  r = zeros(n,1);
  buyLineExtrap = zeros(n,1);

  for i=1:n
    ticker = tickernames{i};
    dataFrequency=cfg.get('dataFrequency');
    if strcmpi(dataFrequency,'week')
      filename = strcat(ticker,'-w.csv');
    else
      filename = strcat(ticker,'-d.csv');
    endif

    f.LoadFile(filename);
    t = f.GetTimestamp;
    x = f.GetValue;
    [lt0,gt0] = f.GetIQM(x);
    [r(i),buyLineExtrap(i),m]=f.WhatToBuyBatch;
    [num,ror,~]=f.CalcReturn;
    emaTest = f.TestEMA();

    [signal,macd,~,~] = f.MACD.CalcMACD(x);
    vel = macd;
    acc = macd-signal;

    numAccelValsOutput = cfg.get('NumAccelValsOutput');
    n = min(numAccelValsOutput,length(x)); % consider last numAccelValsOutput values
    v = sprintf('%.2f;',vel(end-n:end));
    v(end) = [];
    a = sprintf('%.2f;',acc(end-n:end));
    a(end) = [];

    clear ff;
    ff = YahooFunFile;
    if equityFlag
      ff.LoadFile(strcat(ticker,'.csv'));
      fundamentals = ff.GetFundamentalsLast;
    else
      fundamentals = ff.GetFundamentalsZero;
    endif

    fmt = [...
          '%s,'...    % filename
          '%d,'...    % r(i)
          '%d,'...    % emaTest
          '%.2f,'...  % x(end)
          '%.2f,'...  % gt0
          '%.2f,'...  % x(end)+gt0
          '%.2f,'...  % lt0
          '%.2f,'...  % x(end)+lt0
          '%.2f,'...  % buyLineExtrap(i)
          '[%.2f:%.2f],'... % buyLineExtrap(i)+lt0,buyLineExtrap(i)+gt0
          '%d,'...    % num
          '%.2f,'...  % ror
          '%.2f,'...  % m
          '%s,'...    % v
          '%s,'...    % a
          '%.2f,'...  % trailingPE
          '%.2f,'...  % forwardPE
          '%ld,'...   % netIncomeToCommon
          '%ld,'...   % freeCashflow
          '%.2f,'...  % epsCurrentYear
          '%.2f,'...  % earningsGrowth
          '%.2f\n'... % pegRatio
          ];

    fprintf(fid, fmt,...
      filename,...
      r(i),...
      emaTest,...
      x(end),...
      gt0,...
      x(end)+gt0,...
      lt0,...
      x(end)+lt0,...
      buyLineExtrap(i),...
      buyLineExtrap(i)+lt0,buyLineExtrap(i)+gt0,...
      num,...
      ror,...
      m,...
      v,...
      a,...
      fundamentals.trailingPE,
      fundamentals.forwardPE,
      fundamentals.netIncomeToCommon,
      fundamentals.freeCashflow,
      fundamentals.epsCurrentYear,
      fundamentals.earningsGrowth,
      fundamentals.pegRatio);
  endfor
endfunction

