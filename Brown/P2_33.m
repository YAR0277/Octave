format long;

addpath(genpath('../Common'));

M=8;
% Note: increasing time span (N=2048) smooths out experimental estimate of true auto correlation function.
% see comment P2.34(c), Brown.
N=1024;
dt=0.05;
X = zeros(M,N);

% generate/plot a White sequence
figure;
plot(1:N,RandomSequence.GenerateWhiteSequence(1,N));
title('White Sequence');

s=rng;
% generate Gauss-Markov random sequences with M=1..8 different seeds
rng(1);X(1,:) = RandomSequence.GenerateGaussMarkov(dt,N);
rng(2);X(2,:) = RandomSequence.GenerateGaussMarkov(dt,N);
rng(3);X(3,:) = RandomSequence.GenerateGaussMarkov(dt,N);
rng(4);X(4,:) = RandomSequence.GenerateGaussMarkov(dt,N);
rng(5);X(5,:) = RandomSequence.GenerateGaussMarkov(dt,N);
rng(6);X(6,:) = RandomSequence.GenerateGaussMarkov(dt,N);
rng(7);X(7,:) = RandomSequence.GenerateGaussMarkov(dt,N);
rng(8);X(8,:) = RandomSequence.GenerateGaussMarkov(dt,N);

% (a)
figure;
plot(1:N,X(1,:));
title('a. Gauss-Markov Process with seed M=1');

% (b)
lags = 0:dt:3;
V=DSP.CalcAutoCorrelationFcn(X(1,:),lags,N);
fprintf('<Info> The approximate mean square value of the process is %.4f\n',V(1));

R = @(s,b,t) (s^2)*exp(-b*abs(t)); % exact auto-correlation function
t = 0:dt:3.0;
figure;
plot(t,R(1,1,t),'k.');
hold on;
plot(t,V,'-.');
title('b. Auto Correlation Function');
legend('exact','approximate');

% (c)
V = zeros(M,numel(lags));
V(1,:) = DSP.CalcAutoCorrelationFcn(X(1,:),lags,N);
V(2,:) = DSP.CalcAutoCorrelationFcn(X(2,:),lags,N);
V(3,:) = DSP.CalcAutoCorrelationFcn(X(3,:),lags,N);
V(4,:) = DSP.CalcAutoCorrelationFcn(X(4,:),lags,N);
V(5,:) = DSP.CalcAutoCorrelationFcn(X(5,:),lags,N);
V(6,:) = DSP.CalcAutoCorrelationFcn(X(6,:),lags,N);
V(7,:) = DSP.CalcAutoCorrelationFcn(X(7,:),lags,N);
V(8,:) = DSP.CalcAutoCorrelationFcn(X(8,:),lags,N);

figure;
plot(t,R(1,1,t),'k.');
hold on;
plot(t,V(1,:),'-.');
plot(t,(V(1,:)+V(2,:))/2,'-.');
plot(t,(V(1,:)+V(2,:)+V(3,:)+V(4,:))/4,'-.');
plot(t,(V(1,:)+V(2,:)+V(3,:)+V(4,:)+V(5,:)+V(6,:)+V(7,:)+V(8,:))/8,'-.');
title('c. Convergence of Auto Correlation Functions');
legend('exact','avg1','avg2','avg4','avg8');

rng(s);
