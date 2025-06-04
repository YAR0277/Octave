clear all;
f=Finput;
f.SetFolder('index');
f.SetFile('2025-05-06-fidelity-SPX-w.csv');
f.SetSymbol('SPX');
R=Returns(f);
R.YTD;
R.Stats
R.BarYTD

