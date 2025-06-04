clear all;
f=Finput;
f.SetFolder('index');
f.SetFile('2025-05-29-fidelity-BRK_B-d.csv');
f.SetSymbol('BRKB');
rsi=RSI(f);
rsi.SetWindowLength(30);
rsi.SetWeightVector([1:14]);
rsi.SetAlpha(0.5);
rsi.PlotRSI('SMA')
rsi.PlotRS('SMA')
##rsi.Compare();
