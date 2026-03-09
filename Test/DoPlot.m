function [] = DoPlot(ticker)

  baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
  projectsFolder = fullfile(baseFolder,'Projects');
  octaveFolder = fullfile(projectsFolder,'Octave');

  addpath(fullfile(octaveFolder,'Common'));
  addpath(fullfile(octaveFolder,'Finance'));

  z=IntradayFile;
  z.SetFolder('intraday');
  filename = strcat(ticker,'-i.csv');
  z.LoadFile(filename);
  z.Plot;

endfunction

