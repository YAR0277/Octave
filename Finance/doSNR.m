function [] = doSNR()

  addpath(genpath('../Common/'));
  addpath(genpath('../Signals/'));

  finput = Finput(fullfile('Input','DJI-m.txt'));
  monthly = Process(finput);
  Print(monthly);

  finput = Finput(fullfile('Input','DJI-w.txt'));
  weekly = Process(finput);
  Print(weekly);

  finput = Finput(fullfile('Input','DJI-d.txt'));
  daily = Process(finput);
  Print(daily);

  Plot(monthly,weekly,{'monthly','weekly'});
  Plot(monthly,daily,{'monthly','daily'});
endfunction

function [] = Plot(data1,data2,legendStr)
  figure;
  hold on;
  plot(data1.t,data1.noise,'--.','Color',Color.Magenta,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);
  plot(data2.t,data2.noise,'--.','Color',Color.Grey,'MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

  [xticks,fmt] = Util.GetDateTicks(data1.t); %this.GetTimeTicks(t);
  ax = gca;
  set(ax,"XTick",xticks);
  datetick('x',fmt,'keepticks','keeplimits');
  xlim([data1.t(1) data1.t(end)]);

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
  [result.signal,result.s] = Util.GetSignal(t,x);
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
    result.snr,result.pn,norm(result.resid));
endfunction


