% comparePrice(finput) - function to compare (day,week,month) prices of financial data
function [] = comparePrice(finput)
  % finput - instance of Finput

  pkg load io;

  if ~isa(finput, 'Finput')
    return;
  endif

  figure;
  hold on;

  finput.SetFile('2025-06-11-fidelity-BKLC-w.csv');
  [s] = readf(finput);
  plot(s.Date,s.(finput.dataCol),'--.','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

  finput.SetFile('2025-06-11-fidelity-BKLC-m.csv');
  [s] = readf(finput);
  plot(s.Date,s.(finput.dataCol),'--.','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

  finput.SetFile('2025-06-11-fidelity-BKLC-q.csv');
  [s] = readf(finput);
  plot(s.Date,s.(finput.dataCol),'--.','MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

  hold off;

  [xticks,fmt] = Futil.GetDateTicks(s.Date);
  ax = gca;
  set(ax,"XTick",xticks);
  datetick('x',fmt,'keepticks','keeplimits');
  xlim([xticks(1) xticks(end)]);

  legend({'week','month','quarter'},'FontSize',Futil.LegendFontSize);
  ylabel('Price ($)', 'FontSize', Futil.YLabelFontSize);
  title(finput.symbol, 'FontSize', Futil.TitleFontSize);
  grid on;
  grid minor;
endfunction


