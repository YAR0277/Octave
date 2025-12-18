function [] = CmpAreaSphere(this)
  % compares area of envelope (AE) calculated with ellipsoidal to spherical geometry.

  this.RemoveState('AK');
  this.RemoveState('HI');

  T = this.DistrictTable; % short-hand
  [~,idx] = sort(T.midlat); % sort table according to midlat values
  sT = T(idx,:);
  sCol = sT.midlat;

  n = height(sT);
  dAE = sT.AE - sT.AE_sphere;
  [x,ix] = min(dAE);
  fprintf('min value (%.4f) occurs at latitude (%.4f), district (%s)\n',x,sT.midlat(ix),sT.dname{ix,1});
  sT{ix,:}

  [x,ix] = max(dAE);
  fprintf('max value (%.4f) occurs at latitude (%.4f), district (%s)\n',x,sT.midlat(ix),sT.dname{ix,1});
  sT{ix,:}

  figure;
  plot(1:n,dAE,'--.');
  grid on;
  xlabel('District Number');
  ylabel('Area Difference (km^2)');

  re = abs(sT.AE - sT.AE_sphere) ./ sT.AE; % re - relative error
  rep = 100*re; % rep - relative error percent
  [x,ix] = min(rep);
  fprintf('min relative error in percent (%.4f) occurs at latitude (%.4f)\n',x,sT.midlat(ix));
  [x,ix] = max(rep);
  fprintf('max relative error in percent (%.4f) occurs at latitude (%.4f)\n',x,st.midlat(ix));

  figure;
  plot(1:n,rep,'--.');
  grid on;
  xlabel('District Number');
  ylabel('Relative Error in Percent');

  this.Restore;
endfunction
