% plotf(fidelityFile) - function to plot financial data
function [] = plotf(fidelityFile)
  % fidelityFile - instance of FidelityFile

  pkg load io;

  if ~isa(fidelityFile, 'FidelityFile')
    return;
  endif

  s = readf(fidelityFile);
  t = s.Date;
  x = s.(fidelityFile.dataCol);

  figure;
  subplot(2,1,1);
  plot(t(2:end),x(2:end),'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

  [xticks,fmt] = Util.GetDateTicks(s.Date);
  ax = gca;
  set(ax,"XTick",xticks);
  datetick('x',fmt,'keepticks','keeplimits');
  xlim([xticks(1) xticks(end)]);

  legend(fidelityFile.dataCol,'FontSize',Constant.LegendFontSize);
  ylabel(GetLabelY(fidelityFile), 'FontSize', Constant.YLabelFontSize);
  title(fidelityFile.symbol, 'FontSize', Constant.TitleFontSize);

  grid on;
  grid minor;

  subplot(2,1,2);
  r = Returns(fidelityFile);
  r.Subplot();

endfunction
% Ref.: search string "octave read in datatime from csv"
%                     "octave plot with datestr"

function [r] = GetLabelY(fidelityFile)
  switch fidelityFile.dataCol
    case {'Open','High','Low','Close'}
      r = 'Price ($)';
    case 'Volume'
      r = 'Number';
    otherwise
      r = '';
  endswitch
endfunction

