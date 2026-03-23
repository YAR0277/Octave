function [] = DoPlot(ticker)

  baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
  projectsFolder = fullfile(baseFolder,'Projects');
  octaveFolder = fullfile(projectsFolder,'Octave');

  addpath(fullfile(octaveFolder,'Common'));
  addpath(fullfile(octaveFolder,'Finance'));

  z=IntradayFile;
  filename = strcat(ticker,'-i.csv');
  z.LoadFile(filename);
  z.Plot;

  t = z.GetTimestamp;
  x = z.GetValue;

  n = min(10,length(x)); % consider last 10 minutes
  [vals,coeffs] = Util.GetSignal(t(end-n+1:end),x(end-n+1:end));

  fprintf('Median price = %.2f, Midrange price = %.2f, Slope of signal (last 10 values) = %.2f\n',...
    median(x), (min(x)+max(x))/2, coeffs(1));

endfunction

