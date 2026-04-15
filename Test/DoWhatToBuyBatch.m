function [] = DoWhatToBuyBatch(fid,f,tickernames)
  n = numel(tickernames);
  r = zeros(n,1);
  buyLineExtrap = zeros(n,1);

  for i=1:n
    filename = tickernames{i};
    filename = strcat(filename,'-d.csv');
    f.LoadFile(filename);
    p=Price(f);
    x=p.GetPrices;
    [lt0,gt0] = p.GetIQM(x);
    [r(i),buyLineExtrap(i),m]=p.WhatToBuyBatch;
    returns=Returns(f);
    [num,ror,~]=returns.WhatToBuyBatch;
    fprintf(fid, ...
      '%s,%d,%.2f,%.2f,%.2f,[%.2f:%.2f],%d,%.2f\n',...
      filename,...
      r(i),...
      x(end),...
      m,...
      buyLineExtrap(i),...
      buyLineExtrap(i)+lt0,buyLineExtrap(i)+gt0,...
      num,ror);
    clear p;
  endfor
endfunction

