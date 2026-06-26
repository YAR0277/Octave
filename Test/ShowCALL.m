function [] = ShowCALL(ticker,numdays)

  baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
  projectsFolder = fullfile(baseFolder,'Projects');
  octaveFolder = fullfile(projectsFolder,'Octave');
  batchFolder = fullfile(projectsFolder,'Batch');

  addpath(fullfile(octaveFolder,'Common'));
  addpath(fullfile(octaveFolder,'Finance'));

  dataFolder = fullfile(baseFolder,'data','finance');
  optionsFolder = fullfile(dataFolder,'options');

  f=OptionsFile;
  filename = strcat(ticker,'-o.csv');

  if exist(fullfile(optionsFolder,filename), "file") ~= 2
    error("File not found: %s\n",filename);
  endif

  f.LoadFile(filename);
  o=Options(f);
  o.ShowCalls(numdays);

endfunction

