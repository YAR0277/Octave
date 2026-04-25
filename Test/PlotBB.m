function [] = PlotBB(ticker)

  baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
  projectsFolder = fullfile(baseFolder,'Projects');
  octaveFolder = fullfile(projectsFolder,'Octave');

  addpath(fullfile(octaveFolder,'Common'));
  addpath(fullfile(octaveFolder,'Finance'));

  dataFolder = fullfile(baseFolder,'data','finance');
  equityFolder = fullfile(dataFolder,'equity');
  etfFolder = fullfile(dataFolder,'etf');
  indexFolder = fullfile(dataFolder,'index');

  y=YahooFile;

  filename = strcat(ticker,'-d.csv');
  if exist(fullfile(equityFolder,filename), "file") == 2
    y.SetFolder('equity');
  elseif exist(fullfile(etfFolder,filename), "file") == 2
    y.SetFolder('etf');
  elseif exist(fullfile(indexFolder,filename), "file") == 2
    y.SetFolder('index');
  else
    error("File not found: %s\n",filename);
  endif

  y.LoadFile(filename);
  y.PlotBB;

endfunction

