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

  [signal,macd,~,~] = z.MACD.CalcMACD(x);
  vel = macd;
  acc = macd-signal;

  n = min(5,length(x)); % consider last 5 minutes
  [vals,coeffs] = Util.GetSignal(t(end-n+1:end),x(end-n+1:end));

  fprintf('Median price = %.2f, Midrange price = %.2f\n',median(x), (min(x)+max(x))/2);
  fprintf('Slope of signal (last 5 values) = %.2f\n',coeffs(1));
  fprintf('Velocity (last 5):\t');
  fprintf('%10.2f ',vel(end-n+1:end));
  fprintf('\n');
  fprintf('Acceleration (last 5):\t');
  fprintf('%10.2f ',acc(end-n+1:end));
  fprintf('\n');

endfunction

