function [] = DoWhenToBuy(fid,f,tickernames)
  n = numel(tickernames);
  r = zeros(n,1);

  for i=1:n
    filename = tickernames{i};
    filename = strcat(filename,'-d.csv');
    f.LoadFile(filename);
    p=Price(f);
    x=p.GetPrices;
    r(i)=p.WhenToBuyBatch;
    fprintf(fid, 'file: (%s), result: (%d), last price (%.2f)\n',filename,r(i),x(end));
    clear p;
  endfor
endfunction

