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
    fprintf('index(%d),district(%s),minlon(%.4f),maxlon(%.4f),minlat(%.4f),maxlat(%.4f),AD(%.4f),PD(%.4f),AE(%.4f),AE_sphere(%.4f),AE_flatland(%.4f),GE_score(%.4f),GE_sphere(%.4f),GE_flatland(%.4f),PP_score(%.4f)\n',...
      i,T.dname{i,1},T.minlon(i),T.maxlon(i),T.minlat(i),T.maxlat(i),...
      T.AD(i),T.PD(i),T.AE(i),T.AE_sphere(i),T.AE_flatland(i),...
      T.GE_score(i),T.GE_sphere(i),T.GE_flatland(i),T.PP_score(i));
  endif
endfunction
