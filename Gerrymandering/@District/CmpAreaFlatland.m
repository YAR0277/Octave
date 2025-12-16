function [] = CmpAreaFlatland(this)
  % compares area of envelope (AE) calculated with ellipsoidal to spherical geometry.

  this.RemoveState('AK');
  this.RemoveState('HI');

  T = this.DistrictTable; % short-hand
  [~,idx] = sort(T.AD);
  sT = T(idx,:);

  n = height(sT);
  dAE = sT.AE - sT.AE_flatland;
  [x,ix] = min(dAE);
  fprintf('min value (%.4f) occurs at index (%d)\n',x,ix);
  sT{ix,:}

  [x,ix] = max(dAE);
  fprintf('max value (%.4f) occurs at index (%d)\n',x,ix);
  sT{ix,:}

  figure;
  plot(1:n,dAE,'--.');
  grid on;
  xlabel('District Number');
  ylabel('Area Difference (km^2)');

  re = abs(sT.AE - sT.AE_flatland) ./ sT.AE; % re - relative error
  rep = 100*re; % rep - relative error percent
  [x,ix] = min(rep);
  fprintf('min relative error in percent (%.4f) occurs at index (%d)\n',x,ix);
  [x,ix] = max(rep);
  fprintf('max relative error in percent (%.4f) occurs at index (%d)\n',x,ix);

  figure;
  plot(1:n,rep,'--.');
  grid on;
  xlabel('District Number');
  ylabel('Relative Error in Percent');

  this.Restore;
endfunction
