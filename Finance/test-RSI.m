##clear all;
f=Finput;
f.SetFolder('equity');
f.SetFile('2025-05-10-fidelity-VZ-m.csv');
f.SetSymbol('VZ');
rsi=RSI(f);
rsi.SetWindowLength(14);
rsi.SetWeightVector([1:14]);
rsi.SetAlpha(0.5);
rsi.PlotRSI('SMA')
rsi.PlotRS('SMA')
##rsi.Compare();
