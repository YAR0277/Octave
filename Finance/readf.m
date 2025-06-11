% readf(finput) - function to read financial data using Finput
function [s] = readf(finput)
  % finput - instance of Finput

  pkg load io;

  if ~isa(finput, 'Finput')
    return;
  endif

  data=csv2cell(fullfile(finput.dataFolder,finput.fileName));
  timestampCol=1; % col 1 is for timestamp
  firstDataRow=2; % row 1 is for header

  % Date,Open,High,Low,Close,% Change,% Change vs Average,Volume
  s = struct('Date',0,'Open',0,'High',0,'Low',0,'Close',0,'pctChange',0,'pctChangeAvg',0,'Volume',0);

  % Date values
  if finput.descendFlag
    s.Date=datenum(flip(data(firstDataRow:end,timestampCol)),finput.dateFormat);
  else
    s.Date=datenum(data(firstDataRow:end,timestampCol),finput.dateFormat);
  endif

  fieldname = 'Open';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(finput,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'High';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(finput,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'Low';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(finput,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'Close';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(finput,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'pctChange';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(finput,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'pctChangeAvg';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(finput,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'Volume';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(finput,s,fieldname,uint32(GetData(data,firstDataRow,ixCol)));

endfunction

function [r] = GetData(data,firstRow,col)

  % fill empty data values with 0
  ix = find(cellfun(@isempty,data(firstRow:end,col)));
  ix = ix + (firstRow-1); % account for header row
  data(ix,col) = 0;

  % get the data
  r = cell2mat(data(firstRow:end,col));
endfunction

function [s] = SetData(finput,s,fieldname,v)
  if finput.descendFlag
    s.(fieldname) = flip(v);
  else
    s.(fieldname) = v;
  endif
endfunction


