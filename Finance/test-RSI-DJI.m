clear all;
f=Finput;
f.SetFolder('index');
f.SetFile('2025-05-06-fidelity-DJI-m.csv');
f.SetSymbol('DJI');
rsi=RSI(f);
rsi.SetWindowLength(14);
rsi.SetWeightVector([1:14]);
rsi.SetAlpha(0.5);
rsi.PlotRSI('SMA')
rsi.PlotRS('SMA')
##rsi.Compare();
