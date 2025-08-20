function [] = doSNR()

  addpath('c:/Users/drdav/Projects/Octave/Common/Signals');

  finput = Finput('Input\DJI-m.txt');
  monthly = Process(finput);
  Print(monthly);

  finput = Finput('Input\DJI-w.txt');
  weekly = Process(finput);
  Print(weekly);

  finput = Finput('Input\DJI-d.txt');
  daily = Process(finput);
  Print(daily);

  Plot(monthly,weekly,{'monthly','weekly'});
  Plot(monthly,daily,{'monthly','daily'});
endfunction

function [] = Plot(data1,data2,legendStr)
  figure;
  hold on;
  plot(data1.t,data1.noise,'--.','Color',[1,0,1],'MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);
  plot(data2.t,data2.noise,'--.','Color',[.5,.5,.5],'MarkerSize',Futil.PlotMarkerSize,'LineWidth',Futil.PlotLineWidth);

  [xticks,fmt] = Futil.GetDateTicks(data1.t); %this.GetTimeTicks(t);
  ax = gca;
  set(ax,"XTick",xticks);
  datetick('x',fmt,'keepticks','keeplimits');
  xlim([xticks(1) xticks(end)]);

  ylabel('Noise(Points)','FontSize',14);
  legend(legendStr{1},legendStr{2});
  grid on;
  grid minor;
  hold off;
endfunction

function [result] = Process(finput)
  clear result;
  clear r;
  r = ReturnsD2D(finput);
  r.GetReturnData(); % fills returns
  t = r.timestamp;
  x = r.data.Close;
  [result.signal,result.s] = Sutil.GetSignal(t,x);
  result.noise  = Sutil.GetNoise(t,x);
  result.snr    = Sutil.SNR(t,x);
  result.ps     = Sutil.GetSignalPower(t,x);
  result.pn     = Sutil.GetNoisePower(t,x);
  result.resid  = Sutil.GetResidual(t,x);
  result.t = t;
  result.x = x;
endfunction

function [] = Print(result)
  fprintf('SNR=%.2f dB, Noise=%.2f, Norm of residual=%.2f\n',...
    result.snr,result.pn,result.s.normr);
endfunction


