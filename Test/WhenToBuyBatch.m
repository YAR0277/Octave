clear all;

addpath('C:/Users/drdav/Projects/Octave/Common');
addpath('C:/Users/drdav/Projects/Octave/Finance');

f=YahooFile;
f.DataFolder = 'C:/Users/drdav/data/finance';
f.SetFolder('etf');

fid = fopen('WhenToBuyBatchResult.txt','w');

filenames={'IVV-d.csv','IWB-d.csv'};
n = numel(filenames);
r = zeros(n,1);

for i=1:n
	f.LoadFile(filenames{i});
	p=Price(f);
  x=p.GetPrices;
	r(i)=p.WhenToBuyBatch;
	fprintf(fid, 'file: (%s), result: (%d), last price (%.2f)\n',filenames{i},r(i),x(end));
	clear p;
endfor
fclose(fid);

