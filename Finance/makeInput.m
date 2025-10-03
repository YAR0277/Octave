date = '2025-09-30';
symbolList = {...
##  'DJI',...
  'PLTR',...
  'FDD',...
  'FGD',...
  'IVV',...
  'IWB'...
  };

n = length(symbolList);
for i=1:n

  symbol = symbolList{i};

  clear f;
  f=FidelityFile;
  f.SetFolder('etf');
  f.SetFile(strcat(date,'-fidelity-',strcat(symbol,'-d.csv')));
  f.SetSymbol(symbol);
  f.Save(strcat(symbol,'-d')); % TODO

  clear f;
  f=FidelityFile;
  f.SetFolder('etf');
  f.SetFile(strcat(date,'-fidelity-',strcat(symbol,'-w.csv')));
  f.SetSymbol(symbol);
  f.Save(strcat(symbol,'-w')); % TODO
endfor
