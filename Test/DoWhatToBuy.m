function [] = DoWhatToBuy(fid,f,tickernames)
  n = numel(tickernames);
  r = zeros(n,1);
  buyLineExtrap = zeros(n,1);

  for i=1:n
    filename = tickernames{i};
    filename = strcat(filename,'-d.csv');
    f.LoadFile(filename);
    p=Price(f);
    x=p.GetPrices;
    [r(i),buyLineExtrap(i)]=p.WhatToBuyBatch;
    returns=Returns(f);
    [num,ror,apr]=returns.WhatToBuyBatch;
    fprintf(fid, 'file: (%s), result: (%d), last price (%.2f), buy line extrap (%.2f), Nr. (%d), ROR (%.2f), APR (%.2f)\n',...
      filename,r(i),x(end),buyLineExtrap(i),num,ror,apr);
    clear p;
  endfor
endfunction

