function [r] = LookupDistrictArea(T,districtName)
  % returns area of district [km^2]
  r = 0;
  ix = find(T.officeid == districtName);
  if ~isempty(ix)
    areaM2 = T.aland(ix);
    r = areaM2 * 1e-6; % convert to km2
  endif
endfunction
