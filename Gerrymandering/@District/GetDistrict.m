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
    fprintf('index(%d),district(%s),minlon(%.4f),maxlon(%.4f),minlat(%.4f),maxlat(%.4f),AD(%.4f),PD(%.4f),AR_sphere(%.4f),AR_spheroid(%.4f),AR_flatland(%.4f),RR_sphere(%.4f),RR_spheroid(%.4f),RR_flatland(%.4f),PP_score(%.4f)\n',...
      i,T.dname{i,1},T.minlon(i),T.maxlon(i),T.minlat(i),T.maxlat(i),...
      T.AD(i),T.PD(i),T.AR_sphere(i),T.AR_spheroid(i),T.AR_flatland(i),...
      T.RR_sphere(i),T.RR_spheroid(i),T.RR_flatland(i),T.PP_score(i));
  endif
endfunction
