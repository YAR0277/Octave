classdef Config < handle
  % config class
  % ChatGPT

  properties
    data  % struct to store config data key-value pairs
  endproperties

  methods (Access = private)
    function obj = Config(fileName)
      % c'tor returns a Config object
      if nargin > 0
        obj.data = obj.readFile(fileName);
      else
        obj.data = struct();
      endif
    endfunction
  endmethods

  methods (Static)
    function obj = Instance(fileName)
      persistent uniqueInstance;

      if isempty(uniqueInstance)
        if nargin == 0
          error("First call must provide config filename");
        endif
        uniqueInstance = Config(fileName);
      endif

      obj = uniqueInstance;
    endfunction
  endmethods

  methods % Public
    function [r] = get(this,key)
      if isfield(this.data,key)
        r = this.data.(key);
      else
        error("Key not found: ",key);
      endif
    endfunction

    function [] = set(this,key,value)
      this.data.(key) = value;
    endfunction
  endmethods

  methods (Access = private)
    function [data] = readFile(~,fileName)
      % reads config text file and stores as struct
      fid = fopen(fileName, 'r');
      if fid == -1
        error(["Cannot open file: ", fileName]);
      end

      data = struct();
      while ~feof(fid)
        line = strtrim(fgetl(fid));

        % skip empty lines and comments
        if isempty(line) || startsWith(line, '#')
          continue;
        end

        parts = strsplit(line, '=');
        if numel(parts) ~= 2
            continue; % ignore malformed lines
        end

        key = strtrim(parts{1});
        value = strtrim(parts{2});

        % convert value
        data.(key) = Config.parseValue(value);
      endwhile

      fclose(fid);
    endfunction
  endmethods

  methods (Static, Access = private)
      function [r] = parseValue(value)
          % numeric
          num = str2double(value);
          if ~isnan(num)
              r = num;
              return;
          end

          % boolean
          if strcmpi(value, 'true')
              r = true;
          elseif strcmpi(value, 'false')
              r = false;
          else
              r = value; % string
          end
      endfunction
  endmethods
endclassdef
