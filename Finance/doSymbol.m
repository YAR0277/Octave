function [] = doSymbol(varargin)
  switch nargin
    case 1
      symbol = varargin{1};
      bShowPlot = 0;
    case 2
      symbol = varargin{1};
      bShowPlot = varargin{2};
    otherwise
      error('invalid number of arguments %d. \n',nargin);
  endswitch

  [fday,fweek,fref] = GetFinput(symbol);
  p = Price(fday);
  p.Stats
  r = Returns(fweek);
  r.Stats
  c = CSI(fday,fref);
  c.Stats
  if bShowPlot
    p.Plot;
    r.Plot;
    b = BB(fweek);
    b.Plot;
    m = MACD(fday);
    m.Plot;
    s = StoOsc(fday);
    s.Plot;
    plotf(fweek);
  endif
endfunction

function [fday,fweek,fref] = GetFinput(symbol)
  fday  = Finput(strcat('Input\',strcat(symbol,'-d.txt')));
  fweek = Finput(strcat('Input\',strcat(symbol,'-w.txt')));
  fref  = Finput('Input\DJI-d.txt');
endfunction


