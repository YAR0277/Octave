clear all;
f=Finput;
f.SetFolder('index');
f.SetFile('2025-05-06-fidelity-SPX-w.csv');
f.SetSymbol('SPX');
rsi=RSI(f);
rsi.SetWindowLength(30);
rsi.SetWeightVector([1:14]);
rsi.SetAlpha(0.5);
rsi.PlotRSI('SMA')
rsi.PlotRS('SMA')
##rsi.Compare();
