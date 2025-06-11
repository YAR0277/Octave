% comparePrice(finput) - function to compare (day,week,month) prices of financial data
function [] = comparePrice(finput)
  % finput - instance of Finput

  pkg load io;

  if ~isa(finput, 'Finput')
    return;
  endif

  figure;
  hold on;

  finput.SetFile('2025-06-06-fidelity-FDD-d.csv');
  [s] = readf(finput);
  plot(s.Date,s.(finput.dataCol),'--.','MarkerSize',10,'LineWidth',1.0);

  finput.SetFile('2025-06-09-fidelity-FDD-w.csv');
  [s] = readf(finput);
  plot(s.Date,s.(finput.dataCol),'--.','MarkerSize',10,'LineWidth',1.0);

  finput.SetFile('2025-06-09-fidelity-FDD-m.csv');
  [s] = readf(finput);
  plot(s.Date,s.(finput.dataCol),'--.','MarkerSize',10,'LineWidth',1.0);

  hold off;

  [xticks,fmt] = Futil.GetDateTicks(s.Date);
  ax = gca;
  set(ax,"XTick",xticks);
  datetick('x',fmt,'keepticks','keeplimits');
  xlim([xticks(1) xticks(end)]);

  legend({'day','week','month'},'FontSize',14);
  ylabel('Price ($)', 'FontSize', 16);
  title(finput.symbol, 'FontSize', 16);
  grid on;
  grid minor;
endfunction


