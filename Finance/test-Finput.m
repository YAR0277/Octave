clear all;
f=Finput;
f.SetFolder('etf');f.SetFile('2025-06-30-fidelity-GDXJ-d.csv');f.SetSymbol('GDXJ');
f.Save('GDXJ-d');

clear all;
f=Finput;
f.SetFolder('etf');f.SetFile('2025-06-30-fidelity-GDXJ-w.csv');f.SetSymbol('GDXJ');
f.Save('GDXJ-w');

