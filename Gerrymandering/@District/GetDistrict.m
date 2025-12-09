function [] = GetDistrict(this,id)

  T = this.DistrictTable; % short-hand

  n = size(T,1);
  for i=1:n
    theStr = char(T.dname{i,1});
    if length(theStr) < 2
      continue;
    endif

    if strcmp(id,theStr)
      break;
    endif
  endfor

  if (0 < i && i <= n)
    fprintf('index(%d),district(%s),minlon(%.4f),maxlon(%.4f),minlat(%.4f),maxlat(%.4f),AD(%.4f),PD(%.4f),AE_sphere(%.4f),AE_spheroid(%.4f),AE_flatland(%.4f),ER_sphere(%.4f),ER_spheroid(%.4f),ER_flatland(%.4f),PP_score(%.4f)\n',...
      i,T.dname{i,1},T.minlon(i),T.maxlon(i),T.minlat(i),T.maxlat(i),...
      T.AD(i),T.PD(i),T.AE_sphere(i),T.AE_spheroid(i),T.AE_flatland(i),...
      T.ER_sphere(i),T.ER_spheroid(i),T.ER_flatland(i),T.PP_score(i));
  endif
endfunction
