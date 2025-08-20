date = '2025-08-12';
symbolList = {...
  'DJI',...
  'EWG',...
  'FDD',...
  'FGD',...
  'IVV',...
  'IWB'...
  };

n = length(symbolList);
for i=1:n

  symbol = symbolList{i};

  clear f;
  f=Finput;
  f.SetFolder('etf');
  f.SetFile(strcat(date,'-fidelity-',strcat(symbol,'-d.csv')));
  f.SetSymbol(symbol);
  f.Save(strcat(symbol,'-d'));

  clear f;
  f=Finput;
  f.SetFolder('etf');
  f.SetFile(strcat(date,'-fidelity-',strcat(symbol,'-w.csv')));
  f.SetSymbol(symbol);
  f.Save(strcat(symbol,'-w'));
endfor
