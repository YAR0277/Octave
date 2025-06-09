% readf(finput) - function to read financial data using Finput
function [t,x,r] = readf(finput)
  % finput - instance of Finput

  pkg load io;

  if ~isa(finput, 'Finput')
    return;
  endif

  data=csv2cell(fullfile(finput.dataFolder,finput.fileName));
  timestampCol=1; % col 1 is for timestamp
  firstDataRow=2; % row 1 is for header

  % t data values
  if finput.descendFlag
    t=datenum(flip(data(firstDataRow:end,timestampCol)),finput.dateFormat);
  else
    t=datenum(data(firstDataRow:end,timestampCol),finput.dateFormat);
  endif

  % x data values
  headings = strtrim(data(1,:)); % remove spaces
  ixCol = find(strcmpi(finput.dataCol,headings));
  if finput.descendFlag
    x=flip(cell2mat(data(firstDataRow:end,ixCol)));
  else
    x=cell2mat(data(firstDataRow:end,ixCol));
  endif

  % returns
  ixCol = 6; % Date,Open,High,Low,Close,% Change,% Change vs Average,Volume

  % fill empties with 0
  ix = find(cellfun(@isempty,data(firstDataRow:end,ixCol)));
  ix = ix + (firstDataRow-1); % account for header row
  data(ix,ixCol) = 0;

  if finput.descendFlag
    r=flip(cell2mat(data(firstDataRow:end,ixCol)));
  else
    r=cell2mat(data(firstDataRow:end,ixCol));
  endif
endfunction


