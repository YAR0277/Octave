% readf(inFile) - function to read financial data using FidelityFile
function [s] = readf(inFile)
  % inFile - instance of FidelityFile or YahooFile

  pkg load io;

  if ~isa(inFile, 'FidelityFile') && ~isa(inFile, 'YahooFile')
    error('Invalid input file class (%s)\n',class(inFile));
  endif

  if isa(inFile, 'FidelityFile')
    s = struct('Date',0,'Open',0,'High',0,'Low',0,'Close',0,'Volume',0);
  elseif isa(inFile, 'YahooFile')
    s = struct('Date',0,'Close',0,'High',0,'Low',0,'Open',0,'Volume',0);
  endif

  data=csv2cell(fullfile(inFile.DataFolder,inFile.FileName));
  timestampCol=1; % col 1 is for timestamp
  firstDataRow=2; % row 1 is for header

  % Date values
  if inFile.DescendFlag
    s.Date=datenum(flip(data(firstDataRow:end,timestampCol)),inFile.DateFormat);
  else
    s.Date=datenum(data(firstDataRow:end,timestampCol),inFile.DateFormat);
  endif

  fieldname = 'Open';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(inFile,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'High';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(inFile,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'Low';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(inFile,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'Close';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(inFile,s,fieldname,GetData(data,firstDataRow,ixCol));

  fieldname = 'Volume';
  ixCol = find(strcmp(fieldnames(s),fieldname));
  s=SetData(inFile,s,fieldname,uint32(GetData(data,firstDataRow,ixCol)));

endfunction

function [r] = GetData(data,firstRow,col)

  % fill empty data values with 0
  ix = find(cellfun(@isempty,data(firstRow:end,col)));
  ix = ix + (firstRow-1); % account for header row
  data(ix,col) = 0;

  % get the data
  r = cell2mat(data(firstRow:end,col));
endfunction

function [s] = SetData(inFile,s,fieldname,v)
  if inFile.DescendFlag
    s.(fieldname) = flip(v);
  else
    s.(fieldname) = v;
  endif
endfunction


