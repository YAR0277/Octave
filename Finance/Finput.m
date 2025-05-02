% Input structure for financial functions plotf, showf
classdef Finput < handle

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
      obj.dataFolder = 'c:\users\drdav\data\financial'; % financial data folder;
      obj.dateFormat = 'yyyy-mm-dd';
      obj.descendFlag = 0; % data is in ascending order: oldest -> newest
    endfunction

  endmethods
endclassdef
