% function to show financial data raw value

function [] = showf(fileName,typeStr)
  % fileName - file name
  % typeStr - column of data [timestamp,open,low,high,close,volume]

  dataFolder = 'c:\users\drdav\data\financial'; % financial data folder
  data=csv2cell(fullfile(dataFolder,fileName));
  dataRowNr=2; % row 1 is for the header
  typeIdx = find(strcmpi(typeStr,{'timestamp','open','low','high','close','volume'}));
  x=flip(cell2mat(data(dataRowNr:end,typeIdx)))
endfunction


