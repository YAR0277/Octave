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
semilogy(DSP.Periodogram(x,64,1,0),'.-');
semilogy(DSP.Periodogram(x,128,1,0),'.-');
y=DSP.Periodogram(x,256,1,0);
semilogy(y,'.-');
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
t=1:256;
semilogy(t,2./(t.^2+1),'k.');
semilogy(y,'-.');
semilogy(movmean(y,16),'-.');
xlabel('Frequencies (Hz)');
ylabel('Spectrum');
title('d. Smoothing of Periodogram');
legend('exact','y','y16');
grid on;
