format long;

f = @(x,n) chi2pdf(x,n);

% (a)
x=0:.1:8;
figure;
plot(x,f(x,1))
hold on;
plot(x,f(x,2))
plot(x,f(x,4))

% (b)
figure;
plot(x,f(x,16));
hold on;
g = @(x) normpdf(x,16,sqrt(32));
plot(x,g(x));

