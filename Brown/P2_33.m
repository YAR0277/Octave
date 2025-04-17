format long;

addpath(genpath('../Common'));
acs = AutoCorrelationSequence();

M=8;
N=1024;
X = zeros(M,N);

% generate/plot a White sequence
##figure;
##plot(1:N,acs.GenerateWhiteSequence(0,1,N));
##title('White Sequence');

s=rng;
% generate Gauss-Markov random sequences with M=1..8 different seeds
rng(1);X(1,:) = acs.GenerateGaussMarkov(.05,1024);
rng(2);X(2,:) = acs.GenerateGaussMarkov(.05,1024);
rng(3);X(3,:) = acs.GenerateGaussMarkov(.05,1024);
rng(4);X(4,:) = acs.GenerateGaussMarkov(.05,1024);
rng(5);X(5,:) = acs.GenerateGaussMarkov(.05,1024);
rng(6);X(6,:) = acs.GenerateGaussMarkov(.05,1024);
rng(7);X(7,:) = acs.GenerateGaussMarkov(.05,1024);
rng(8);X(8,:) = acs.GenerateGaussMarkov(.05,1024);

% (a)
figure;
plot(1:N,X(1,:));
title('a. Gauss-Markov Process with seed M=1');

% (b)
lags = 0:.05:3;
V=acs.CalcAutoCorrelationFcn(X(1,:),lags,1024);
fprintf('<Info> The approximate mean square value of the process is %.4f\n',V(1));

R = @(s,b,t) (s^2)*exp(-b*abs(t)); % exact auto-correlation function
t = 0:.05:3.0;
figure;
plot(t,R(1,1,t),'k.');
hold on;
plot(t,V,'-.');
title('b. Auto Correlation Function');
legend('exact','approximate');

% (c)
V = zeros(M,numel(lags));
V(1,:) = acs.CalcAutoCorrelationFcn(X(1,:),lags,1024);
V(2,:) = acs.CalcAutoCorrelationFcn(X(2,:),lags,1024);
V(3,:) = acs.CalcAutoCorrelationFcn(X(3,:),lags,1024);
V(4,:) = acs.CalcAutoCorrelationFcn(X(4,:),lags,1024);
V(5,:) = acs.CalcAutoCorrelationFcn(X(5,:),lags,1024);
V(6,:) = acs.CalcAutoCorrelationFcn(X(6,:),lags,1024);
V(7,:) = acs.CalcAutoCorrelationFcn(X(7,:),lags,1024);
V(8,:) = acs.CalcAutoCorrelationFcn(X(8,:),lags,1024);

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
