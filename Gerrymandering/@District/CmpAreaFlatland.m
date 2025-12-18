function [] = CmpAreaFlatland(this,col)
  % compares area of envelope (AE) calculated with ellipsoidal to spherical geometry.

  this.RemoveState('AK');
  this.RemoveState('HI');

  T = this.DistrictTable; % short-hand
  [~,idx] = sort(T.(col)); % sort table according to col values
  sT = T(idx,:);
  sCol = sT.(col);

  n = height(sT);
  dAE = sT.AE - sT.AE_flatland;
  [x,ix] = min(dAE);
  fprintf('min value (%.4f) occurs at index (%d), district (%s), col value(%.4f)\n',x,ix,sT.dname{ix,1},sCol(ix));
  sT{ix,:}

  [x,ix] = max(dAE);
  fprintf('max value (%.4f) occurs at index (%d), district (%s), col value(%.4f)\n',x,ix,sT.dname{ix,1},sCol(ix));
  sT{ix,:}

  figure;
  plot(1:n,dAE,'--.');
  grid on;
  xlabel('District Number');
  ylabel('Area Difference (km^2)');

  re = abs(sT.AE - sT.AE_flatland) ./ sT.AE; % re - relative error
  fprintf('relative error range: [(%.4f),(%.4f)], mean(%.4f)\n',min(re),max(re),mean(re));

  rep = 100*re; % rep - relative error percent
  fprintf('relative error in percent range: [(%.4f),(%.4f)], mean(%.4f)\n',min(rep),max(rep),mean(rep));

  figure;
  plot(1:n,rep,'--.');
  grid on;
  xlabel('District Number');
  ylabel('Relative Error in Percent');

  this.Restore;
endfunction
