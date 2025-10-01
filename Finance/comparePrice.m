% comparePrice(fidelityFile) - function to compare (day,week,month) prices of financial data
function [] = comparePrice(fidelityFile)
  % fidelityFile - instance of FidelityFile

  pkg load io;

  if ~isa(fidelityFile, 'FidelityFile')
    return;
  endif

  fidelityFile.SetFolder('etf');

  fidelityFile.LoadFile('2025-09-30-fidelity-FDD-d.csv');
  fidelityFile.Plot;

  fidelityFile.LoadFile('2025-09-30-fidelity-FDD-w.csv');
  fidelityFile.Plot;

endfunction


