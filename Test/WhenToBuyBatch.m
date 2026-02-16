clear all;

##baseFolder = fileparts(fileparts(fileparts(pwd()))); % for debugging in Octave

baseFolder = fileparts(fileparts(pwd()));
projectsFolder = fullfile(baseFolder,'Projects');
octaveFolder = fullfile(projectsFolder,'Octave');

addpath(fullfile(octaveFolder,'Common'));
addpath(fullfile(octaveFolder,'Finance'));
addpath(fullfile(octaveFolder,'Test'));

batchFolder = fullfile(projectsFolder,'Batch');

# 1. ETFs
fid_read = fopen(fullfile(batchFolder,'ETF.txt'), 'r');
tickers = textscan(fid_read, '%s');
fclose(fid_read);
tickernames = tickers{1};   % Cell array of strings

f=YahooFile;
f.DataFolder = fullfile(fullfile(baseFolder,'data'),'finance');
f.SetFolder('etf');

fid_write = fopen(fullfile(batchFolder,'WhenToBuyBatchResult.txt'),'w');
DoWhenToBuy(fid_write,f,tickernames);
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

fid_write = fopen(fullfile(batchFolder,'WhenToBuyBatchResult.txt'),'a');
DoWhenToBuy(fid_write,f,tickernames);
fclose(fid_write);


