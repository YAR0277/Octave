% plotf(finput) - function to plot financial data
function [] = plotf(finput)
  % finput - instance of Finput

  pkg load io;

  if ~isa(finput, 'Finput')
    return;
  endif

  [t,x] = showf(finput);

  plot(t,x,'--.');
  datetick('x',finput.dateFormat,'keepticks');
  [~,name,ext] = fileparts(finput.symbol);
  title(name);
  grid on;
endfunction
% Ref.: search string "octave read in datatime from csv"
%                     "octave plot with datestr"


