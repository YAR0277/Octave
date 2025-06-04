classdef Finput < handle
  % Input structure for financial functions plotf, showf and classes Returns

  properties
    dataCol
    dataFolder
    dateFormat
    descendFlag
    fileName
    symbol
  endproperties

  methods % Public

    function [obj] = Finput()
      obj.dataCol = 'close';
      obj.dataFolder = 'c:\users\drdav\data\finance'; % financial data folder;
      obj.dateFormat = 'yyyy-mm-dd';
      obj.descendFlag = 0; % data is in ascending order: oldest -> newest
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
      dir(strcat(this.dataFolder,'\*.csv'))
    endfunction
  endmethods
endclassdef
