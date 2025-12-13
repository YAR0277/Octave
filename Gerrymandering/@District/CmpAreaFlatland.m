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
  fprintf('min value (%.f) occurs at index (%d)\n',x,ix);
  sT{ix,:}

  [x,ix] = max(dAE);
  fprintf('max value (%.f) occurs at index (%d)\n',x,ix);
  sT{ix,:}

  figure;
  plot(1:n,dAE,'--.');
  grid on;
  xlabel('District Number');
  ylabel('Area Difference (km^2)');

  this.Restore;
endfunction
