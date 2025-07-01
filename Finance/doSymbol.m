function [] = doSymbol(symbol)

  [fday,fweek,fref] = GetFinput(symbol);
  p = Price(fday);
  p.Stats
  p.Plot;
  r = Returns(fweek);
  r.Stats
  r.Plot;
  c = CSI(fday,fref);
  c.Stats
  b = BB(fweek);
  b.Plot;
  m = MACD(fday);
  m.Plot;

  plotf(fweek);

endfunction

function [fday,fweek,fref] = GetFinput(symbol)
  fday  = Finput(strcat('Input\',strcat(symbol,'-d.txt')));
  fweek = Finput(strcat('Input\',strcat(symbol,'-w.txt')));
  fref  = Finput('Input\DJI-d.txt');
endfunction


