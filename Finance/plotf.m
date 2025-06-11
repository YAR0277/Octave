% plotf(finput) - function to plot financial data
function [] = plotf(finput)
  % finput - instance of Finput

  pkg load io;

  if ~isa(finput, 'Finput')
    return;
  endif

  [s] = readf(finput);

  figure;
  plot(s.Date,s.(finput.dataCol),'--.');

  [xticks,fmt] = Futil.GetDateTicks(s.Date);
  ax = gca;
  set(ax,"XTick",xticks);
  datetick('x',fmt,'keepticks','keeplimits');
  xlim([xticks(1) xticks(end)]);


  legend(finput.dataCol);
  ylabel(GetLabelY(finput), 'FontSize', 16);
  title(finput.symbol, 'FontSize', 16);
  grid on;
  grid minor;
endfunction
% Ref.: search string "octave read in datatime from csv"
%                     "octave plot with datestr"

function [r] = GetLabelY(finput)
  switch finput.dataCol
    case {'Open','High','Low','Close'}
      r = 'Price ($)';
    case {'pctChange','pctChangeAvg'}
      r = 'Price Change (%)';
    case 'Volume'
      r = 'Number';
    otherwise
      r = '';
  endswitch
endfunction

