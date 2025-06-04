clear all;
f=Finput;
f.SetFolder('index');
f.SetFile('2025-05-29-fidelity-BRK_B-d.csv');
f.SetSymbol('BRKB');
R=Returns(f);
R.YTD;
R.Stats
R.BarYTD

