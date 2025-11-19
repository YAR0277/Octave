function [T] = ReadCsvIntoTable(dataFolder,fname)
  fileName = fullfile(dataFolder,fname);
  fid = fopen(fileName, 'r');
  fin = textscan(fid,"%d %f %f %f %f %s %s", 'Delimiter', ',', 'HeaderLines', 1);
  objectid = fin{1}; % OBJECTID
  aland = fin{2}; % ALAND
  awater = fin{3}; % AWATER
  intptlat = fin{4}; % INTPTLAT
  intptlon = fin{5}; % INTPTLON
  f6 = cell2mat(fin{6}); % OFFICE_ID
  officeid = string(f6(:,:));
  f7 = cell2mat(fin{7}); % PARTY
  party = string(f7(:,:));
  T = table(objectid,aland,awater,intptlat,intptlon,officeid,party);
endfunction
