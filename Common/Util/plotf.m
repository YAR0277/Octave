% function to plot financial data
% Ref.: search string "octave read in datatime from csv"
%                     "octave plot with datestr"
function [] = plotf(fileName,typeStr)
  % fileName - file name
  % typeStr - type of plot [open,low,high,close,volume]

  dataFolder = 'c:\users\drdav\data\financial'; % financial data folder
  data=csv2cell(fullfile(dataFolder,fileName));
  dateTimeColNr=1; % column 1 is Date/Time
  dataRowNr=2; % row 1 is for the header
  timeFormat='mm-dd-yyyy';
  t=datenum(flip(data(dataRowNr:end,dateTimeColNr)),timeFormat);
  typeIdx = find(strcmpi(typeStr,{'timestamp','open','low','high','close','volume'}));
  x=flip(cell2mat(data(dataRowNr:end,typeIdx)));
  plot(t,x,'--.');
  datetick('x',timeFormat,'keepticks');
  [~,name,ext] = fileparts(fileName);
  title(name);
  grid on;
endfunction


