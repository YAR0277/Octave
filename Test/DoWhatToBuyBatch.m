function [] = DoWhatToBuyBatch(fid,f,tickernames)
  n = numel(tickernames);
  r = zeros(n,1);
  buyLineExtrap = zeros(n,1);

  for i=1:n
    filename = tickernames{i};
    filename = strcat(filename,'-d.csv');
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
      '%s,%d,%.2f,%.2f,[%.2f:%.2f],%d,%.2f,%.2f,%s,%s\n',...
      filename,...
      r(i),...
      x(end),...
      buyLineExtrap(i),...
      buyLineExtrap(i)+lt0,buyLineExtrap(i)+gt0,...
      num,ror,...
      m,v,a);
  endfor
endfunction

