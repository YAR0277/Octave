pkg load statistics;

format long;

addpath(genpath('../Common'));

M=1;
N=256;
dt=1.0;
x = zeros(M,N);

% generate Gauss-Markov random sequence
x(1,:) = RandomSequence.GenerateGaussMarkov(dt,N);

% (a)
figure;
plot(1:N,x(1,:),'--.');
xlabel('Sample Number');
ylabel('Sequence Value');
title('a. Gauss-Markov Process, N=256, dt=1.0');

% (b)-(c)
figure;
hold on;
[f,P]=DSP.Periodogram(x,64,1);
plot(f,P);
[f,P]=DSP.Periodogram(x,128,1);
plot(f,P);
[f,P]=DSP.Periodogram(x,256,1);
plot(f,P);
xlabel('Frequencies (Hz)');
ylabel('Spectrum');
title('c. Periodograms, dt=1.0');
legend('N=64','N=128','N=256');
grid on;

% (d)
##https://stackoverflow.com/questions/13013911/averaging-every-n-elements-of-a-vector-in-matlab
%mean(reshape(y,2,[]));
%mean(reshape(y,4,[]));
%mean(reshape(y,8,[]));
figure;
hold on;
%t=0:.01:0.5;
%plot(t,2./(t.^2+1),'k.');
plot(f,P,'-.');
plot(f,movmean(P,16),'-.');
xlabel('Frequencies (Hz)');
ylabel('Spectrum');
title('d. Smoothing of Periodogram');
legend('P','P16');
grid on;
