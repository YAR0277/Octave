clear all;
f=Finput;
f.SetFolder('index');
f.SetFile('2025-05-06-fidelity-DJI-m.csv');
f.SetSymbol('DJI');
R=Returns(f);
R.YTD;
R.Stats
R.BarYTD

