function [] = DoPlot(ticker)

  baseFolder = fileparts(fileparts(pwd()));
  projectsFolder = fullfile(baseFolder,'Projects');
  octaveFolder = fullfile(projectsFolder,'Octave');

  addpath(fullfile(octaveFolder,'Common'));
  addpath(fullfile(octaveFolder,'Finance'));

  z=IntradayFile;
  z.DataFolder = fullfile(fullfile(baseFolder,'data'),'finance');
  z.SetFolder('etf');
  filename = strcat(ticker,'-i.csv');
  z.LoadFile(filename);
  z.Plot;

endfunction

