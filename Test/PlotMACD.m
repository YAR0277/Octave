function [] = PlotMACD(ticker)

  baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
  projectsFolder = fullfile(baseFolder,'Projects');
  octaveFolder = fullfile(projectsFolder,'Octave');
  batchFolder = fullfile(projectsFolder,'Batch');

  addpath(fullfile(octaveFolder,'Common'));
  addpath(fullfile(octaveFolder,'Finance'));

  dataFolder = fullfile(baseFolder,'data','finance');
  equityFolder = fullfile(dataFolder,'equity');
  etfFolder = fullfile(dataFolder,'etf');
  indexFolder = fullfile(dataFolder,'index');

  y=YahooFile;

  cfg = Config(fullfile(batchFolder,'config.txt'));
  dataFrequency=cfg.get('dataFrequency');
  if strcmpi(dataFrequency,'week')
    filename = strcat(ticker,'-w.csv');
  else
    filename = strcat(ticker,'-d.csv');
  endif

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
  y.PlotMACD;

endfunction

