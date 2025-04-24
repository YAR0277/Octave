format long;

addpath(genpath('../Common'));

M=50; % ensemble
N=99; % number of samples in realization
dt=1;
x = zeros(M,N);

% (a) generate Wiener sequences with M=1..11
for k=1:M
  x(k,:) = RandomSequence.GenerateWienerSequence(1,N);
endfor

% (b)
figure;
hold on;
s=[1,22,13,41,49,16,27,38];
for i=1:numel(s)
  plot(x(s(i),:),'.-');
endfor
xlabel('sample number');
ylabel('sample value (x)');
title('b. Wiener Sequences');

% (c)
figure;
x2 = x.^2; % squares of x
plot(mean(x2,1),'.-');
xlabel('sample number');
ylabel('E[x^2]');
title('c. Average Squares of x');

