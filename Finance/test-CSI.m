clear all;
c=CSI(FidelityFile('FDD-d.txt'));
c.AddReference(FidelityFile('DJI-d.txt'));
c.Stats

clear all;
c=CSI(FidelityFile('BKLC-d.txt'));
c.AddReference(FidelityFile('DJI-d.txt'));
c.Stats

clear all;
c=CSI(FidelityFile('FZROX-d.txt'));
c.AddReference(FidelityFile('DJI-d.txt'));
c.Stats

clear all;
c=CSI(FidelityFile('FNILX-d.txt'));
c.AddReference(FidelityFile('DJI-d.txt'));
c.Stats

clear all;
c=CSI(FidelityFile('FXAIX-d.txt'));
c.AddReference(FidelityFile('DJI-d.txt'));
c.Stats

