function [f,P] = doPeriodogram(x,n)

  format long;
  addpath(genpath('../Common'));

% Ex. data from file
##  [x,n]=GetSignalFromFile('DJIND.csv','close');

% Ex. generated data
##  N=500;
##  x=GetSignalCosine(N);

% signal
  figure;
  plot(1:n,x,'--.');
  xlabel('Sample Number');
  ylabel('Signal Value');
  title('Signal');
  grid on;

% periodogram
  figure;
  [f,P]=DSP.Periodogram(x,n,1);
  stem(f,P);
  xlabel('Frequencies');
  ylabel('Spectrum');
  title('Periodogram');
  grid on;
endfunction

function [x] = GetSignalCosine(N)
  t=1:N;
  A=2;
  omega=1/250;
  phi=0.6*pi;
  e1=normrnd(0,1,[1,N]);
  e2=normrnd(0,25,[1,N]);
  x=A*cos(2*pi*omega*t + phi) + A*cos(2*pi*2*omega*t + phi);
endfunction

function [x,n] = GetSignalFromFile(fname,ftype)
  x = showf(fname,ftype);
  n = numel(x);
  if mod(n,2) ~= 0
    n = n-1;
    x = x(1:n);
  endif
endfunction


