function [r] = LookupDistrictName(T,districtName)
  % returns area of district [km^2]
  r = 0;
  ix = find(T.officeid == districtName);
  if ~isempty(ix)
    r = T.officeid(ix);
  endif
endfunction
