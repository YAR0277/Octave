format long;

% density of X ~ N(0,1)
f = @(x) (1/sqrt(2*pi))*exp(-x^2/2);
% Feller's approximation to 1-F_X, where F_X is distribution of X
Fe = @(x) (1./(2*pi.*x)).*exp(-x.^2/2);

% (a)
y=[4,5,6,7,8,9];
Fe(y)
% if y=9, Fe = O(10^-20), this is small enough
a=4.5;b=y(end);
% approximate P(X>4.5) by integrating out to x=9
fprintf('Tail probability P(X>4.5) via integration of pdf: %.12f\n',quad(f,a,b));

% (b)
fprintf('Tail probability via Feller approx. x=4.5: %.12f\n',Fe(4.5));
fprintf('Tail probability via Feller approx. x=6.5: %.12f\n',Fe(6.5));
fprintf('Tail probability via integration of pdf from x=4.5: %.12f\n',quad(f,4.5,b));
fprintf('Tail probability via integration of pdf from x=6.5: %.12f\n',quad(f,6.5,b));

