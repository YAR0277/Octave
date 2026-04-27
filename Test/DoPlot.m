function [] = DoPlot(ticker)

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
  y.Plot;

  t = y.GetTimestamp;
  x = y.GetValue;

  [signal,macd,~,~] = y.MACD.CalcMACD(x);
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

