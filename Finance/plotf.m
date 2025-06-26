% plotf(finput) - function to plot financial data
function [] = plotf(finput)
  % finput - instance of Finput

  pkg load io;

  if ~isa(finput, 'Finput')
    return;
  endif

  s = readf(finput);
  t = s.Date;
  x = s.(finput.dataCol);

  rsi = RSI(finput);

  figure;
  subplot(2,1,1);
  plot(t(2:end),x(2:end),'--.','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

  [xticks,fmt] = Futil.GetDateTicks(s.Date);
  ax = gca;
  set(ax,"XTick",xticks);
  datetick('x',fmt,'keepticks','keeplimits');
  xlim([xticks(1) xticks(end)]);

  legend(finput.dataCol,'FontSize',Futil.LegendFontSize);
  ylabel(GetLabelY(finput), 'FontSize', Futil.YLabelFontSize);
  title(finput.symbol, 'FontSize', Futil.TitleFontSize);

  grid on;
  grid minor;

  subplot(2,1,2);
  rsi.Subplot();

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

