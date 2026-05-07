clear all;

baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
projectsFolder = fullfile(baseFolder,'Projects');
octaveFolder = fullfile(projectsFolder,'Octave');

addpath(fullfile(octaveFolder,'Common'));
addpath(fullfile(octaveFolder,'Finance'));
addpath(fullfile(octaveFolder,'Test'));

batchFolder = fullfile(projectsFolder,'Batch');
cfg = Config.Instance(fullfile(batchFolder,'config.txt'));

# 1. ETFs
fid_read = fopen(fullfile(batchFolder,'ETF.txt'), 'r');
tickers = textscan(fid_read, '%s');
fclose(fid_read);
tickernames = tickers{1};   % Cell array of strings

f=YahooFile;
f.DataFolder = fullfile(baseFolder,'data','finance');
f.SetFolder('etf');

fid_write = fopen(fullfile(batchFolder,'WhatToBuyBatchResult.csv'),'w');
if fid_write == -1
  error("Failed to open output file for writing.");
endif
fprintf(fid_write,"File,Accel Test,EMA Test,Last Price,IQM(+),Max Bid,IQM(-),Sell Limit,Buy Line Extrap,Range,Nr. Samples,ROR,Trend Slope,Velocity,Acceleration\n");
DoWhatToBuyBatch(fid_write,f,tickernames,cfg);
fclose(fid_write);

# 2. Equities
fid_read = fopen(fullfile(batchFolder,'Equity.txt'), 'r');
tickers = textscan(fid_read, '%s');
fclose(fid_read);
tickernames = tickers{1};   % Cell array of strings

clear f;
f=YahooFile;
f.DataFolder = fullfile(fullfile(baseFolder,'data'),'finance');
f.SetFolder('equity');

fid_write = fopen(fullfile(batchFolder,'WhatToBuyBatchResult.csv'),'a');
if fid_write == -1
  error("Failed to open output file for writing.");
endif
DoWhatToBuyBatch(fid_write,f,tickernames,cfg);
fclose(fid_write);


