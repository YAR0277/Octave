format long;

warning('off','all');

n=5000;
p=.001;
P = @(k) nchoosek(n,k)*p^k*(1-p)^(n-k);
Q = @(k) log10(nchoosek(n,k)) + k*log10(p) + (n-k)*log10(1-p);

tol=.01;
Prb=.98;

S=0;k=0;
while 1
  if (Prb-S <= tol)
    break;
  else
    S=S+(P(k));
    k=k+1;
  endif
end

fprintf('k value: %d\n',k);
fprintf('S value: %f\n',S);

S=0;k=0;
while 1
  if (Prb-S <= tol)
    break;
  else
    S=S+10^(Q(k));
    k=k+1;
  endif
end

fprintf('k value: %d\n',k);
fprintf('S value: %f\n',S);

