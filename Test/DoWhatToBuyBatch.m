function [] = DoWhatToBuyBatch(fid,f,tickernames,cfg)
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

    [signal,macd,~,~] = f.MACD.CalcMACD(x);
    vel = macd;
    acc = macd-signal;

    n = min(5,length(x)); % consider last 5 values
    v = sprintf('%.2f;',vel(end-n:end));
    v(end) = [];
    a = sprintf('%.2f;',acc(end-n:end));
    a(end) = [];

    fprintf(fid, ...
      '%s,%d,%.2f,%.2f,%.2f,[%.2f:%.2f],%d,%.2f,%.2f,%s,%s\n',...
      filename,...
      r(i),...
      x(end),...
      gt0,...
      buyLineExtrap(i),...
      buyLineExtrap(i)+lt0,buyLineExtrap(i)+gt0,...
      num,ror,...
      m,v,a);
  endfor
endfunction

