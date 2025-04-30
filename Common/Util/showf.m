% function to show financial data raw value

function [t,x] = showf(fileName,typeStr)
  % fileName - file name
  % typeStr - column of data [timestamp,open,low,high,close,volume]

  pkg load io;

  dataFolder = 'c:\users\drdav\data\financial'; % financial data folder
  data=csv2cell(fullfile(dataFolder,fileName));
  dateTimeColNr=1; % column 1 is Date/Time
  dataRowNr=2; % row 1 is for the header
  timeFormat='mm-dd-yyyy';
  t=datenum(flip(data(dataRowNr:end,dateTimeColNr)),timeFormat);
  typeIdx = find(strcmpi(typeStr,{'timestamp','open','low','high','close','volume'}));
  x=flip(cell2mat(data(dataRowNr:end,typeIdx)));
endfunction


