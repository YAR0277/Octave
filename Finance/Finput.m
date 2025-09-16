classdef Finput < handle
  % Input structure for financial functions plotf, readf and classes Returns

  properties
    dataCol
    dataFolder
    dateFormat
    descendFlag
    fileName
    symbol
  endproperties

  methods % Public

    function [obj] = Finput(varargin)
      obj.dataCol = 'Close'; % 'Open','High','Low','Close','pctChange','pctChangeAvg','Volume'
      obj.dataFolder = '../../../data/finance'; % financial data folder;
      obj.dateFormat = 'yyyy-mm-dd';
      obj.descendFlag = 0; % data is in ascending order: oldest -> newest
      obj.fileName = '';
      obj.symbol = '';

      if ~isempty(varargin)
        obj.Load(varargin{1});
      endif
    endfunction

    function [] = SetFile(this,fileName)
      % sets fileName property
      this.fileName = fileName;
    endfunction

    function [] = SetFolder(this,type)
      % sets dataFolder property
      if ismember(type,{"bond","equity","etf","index"})
        this.dataFolder = fullfile(this.dataFolder,type);
      end
    endfunction

    function [] = SetSymbol(this,symbol)
      % sets symbol property
      this.symbol = symbol;
    endfunction

    function [] = ShowFiles(this)
      % shows all files in dataFolder
      dir(fullfile(this.dataFolder,'*.csv'))
    endfunction

    function [r] = ShowFolders(this)
      % shows all files in dataFolder
      % https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
      folders=dir(this.dataFolder);
      idx=[folders(:).isdir];
      r = {folders(idx).name}';
      r(ismember(r,{'.','..'})) = [];
    endfunction

    function [] = Load(this, fileName)
      fid = fopen(fileName, 'r');
      fin = textscan(fid,"%s %s %s %d %s %s", 'delimiter', '\n');
      this.dataCol = cell2mat(fin{1});
      this.dataFolder = cell2mat(fin{2});
      this.dateFormat = cell2mat(fin{3});
      this.descendFlag = fin{4};
      this.fileName = cell2mat(fin{5});
      this.symbol = cell2mat(fin{6});
    endfunction

    function [] = Save(this,fname)
      filename = fullfile('Input',strcat(fname,".txt"));
      asStruct = this.ToStruct();
      fid = fopen(filename, 'w+');
      fprintf(fid,'%s\n',asStruct.dataCol);
      fprintf(fid,'%s\n',asStruct.dataFolder);
      fprintf(fid,'%s\n',asStruct.dateFormat);
      fprintf(fid,'%d\n',asStruct.descendFlag);
      fprintf(fid,'%s\n',asStruct.fileName);
      fprintf(fid,'%s\n',asStruct.symbol);
      fclose(fid);
    endfunction
  endmethods %Public

  methods (Access = private)
    function [s] = ToStruct(this)
      s = struct();
      fields = fieldnames(this);
      for i=1:length(fields)
        s.(fields{i}) = getfield(this,fields{i});
      endfor
    endfunction
  endmethods
endclassdef
