function [] = doSymbol(varargin)
  % call is doSymbol('2025-09-30','FDD'), doSymbol('2025-09-30','FDD',1)
  addpath(genpath('../Common'));

  switch nargin
    case 2
      fdate = varargin{1};
      symbol = varargin{2};
      bShowPlot = 0;
    case 3
      fdate = varargin{1};
      symbol = varargin{2};
      bShowPlot = varargin{3};
    otherwise
      error('invalid number of arguments %d. \n',nargin);
  endswitch

  [fday,fweek,fref] = GetFinput(fdate,symbol);
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

function [fday,fweek,fref] = GetFinput(fdate,symbol)
  fday  = FidelityFile;
  fday.SetFolder('etf');
  fday.LoadFile(strcat(strcat(strcat(fdate,'-fidelity-'),symbol),'-d.csv'));
  fday.SetSymbol(symbol);

  fweek  = FidelityFile;
  fweek.SetFolder('etf');
  fweek.LoadFile(strcat(strcat(strcat(fdate,'-fidelity-'),symbol),'-w.csv'));
  fweek.SetSymbol(symbol);

  fref  = FidelityFile;
  fref.SetFolder('index');
  fref.LoadFile(strcat(fdate,'-fidelity-DJI-d.csv'));
endfunction


