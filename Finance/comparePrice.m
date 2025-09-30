% comparePrice(fidelityFile) - function to compare (day,week,month) prices of financial data
function [] = comparePrice(fidelityFile)
  % fidelityFile - instance of FidelityFile

  pkg load io;

  if ~isa(fidelityFile, 'FidelityFile')
    return;
  endif

  figure;
  hold on;

  fidelityFile.SetFile('2025-06-11-fidelity-BKLC-w.csv');
  [s] = readf(fidelityFile);
  plot(s.Date,s.(fidelityFile.dataCol),'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

  fidelityFile.SetFile('2025-06-11-fidelity-BKLC-m.csv');
  [s] = readf(fidelityFile);
  plot(s.Date,s.(fidelityFile.dataCol),'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

  fidelityFile.SetFile('2025-06-11-fidelity-BKLC-q.csv');
  [s] = readf(fidelityFile);
  plot(s.Date,s.(fidelityFile.dataCol),'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

  hold off;

  [xticks,fmt] = Util.GetDateTicks(s.Date);
  ax = gca;
  set(ax,"XTick",xticks);
  datetick('x',fmt,'keepticks','keeplimits');
  xlim([xticks(1) xticks(end)]);

  legend({'week','month','quarter'},'FontSize',Constant.LegendFontSize);
  ylabel('Price ($)', 'FontSize', Constant.YLabelFontSize);
  title(fidelityFile.symbol, 'FontSize', Constant.TitleFontSize);
  grid on;
  grid minor;
endfunction


