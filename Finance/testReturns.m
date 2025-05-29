clear all;
f=Finput;
f.SetFolder('index');
f.SetFile('2025-05-08-fidelity-BRK_B-m.csv');
f.SetSymbol('BRK-B');
R=Returns(f);
R.YTD;

