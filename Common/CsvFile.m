classdef CsvFile < handle
  % No Interfaces in Octave (yet)

  methods %Public
    function obj = CsvFile()
      % c'tor to create a CsvFile object, parent object for XXXFile objects.
    endfunction

    function [r] = GetTimestamp(obj)
      r = []; % dummy implementation
      fprintf('Please implement in child class!\n');
    endfunction

    function [r] = GetValue(obj)
      r = [];
      fprintf('Please implement in child class!\n');
    endfunction

  endmethods
endclassdef
