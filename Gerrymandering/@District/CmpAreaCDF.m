function [] = CmpAreaCDF(this,col)
  % compares area of envelope (AE) with AE_flatland, AE_sphere, AE_girard

  pkg load statistics

  this.RemoveState('AK');
  this.RemoveState('HI');

  T = this.DistrictTable; % short-hand

  [F1,x1]=ecdf(T.AE-T.AE_flatland);
  [F2,x2]=ecdf(T.AE-T.AE_sphere);
  [F3,x3]=ecdf(T.AE-T.AE_girard);

  figure;
  hold on;
  plot(x1,F1,'--.');
  plot(x2,F2,'--.');
  plot(x3,F3,'--.');

  grid on;
  legend('Projection','Spherical Approximation','Spherical Geometry');
  xlabel('Area Difference (km^2)');
  hold off;

  this.Restore;
endfunction
