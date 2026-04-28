function [] = PlotEMA(ticker)

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

  cfg = Config.Instance(fullfile(batchFolder,'config.txt'));
  dataFrequency=cfg.get('dataFrequency');

  if strcmpi(dataFrequency,'intraday')
    y=IntradayFile;
    filename = strcat(ticker,'-i.csv');
  else
    y=YahooFile;
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
  endif

  y.LoadFile(filename);
  y.PlotEMA;
  y.ShowMomentum;
endfunction

