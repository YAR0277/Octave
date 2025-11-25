function [r] = LookupDistrictArea(this,districtName)
  % returns area of district [km^2]
  r = 0;
  ix = find(this.CsvTable.officeid == districtName);
  if ~isempty(ix)
    areaM2 = this.CsvTable.aland(ix);
    r = areaM2 * 1e-6; % convert to km2
  endif
endfunction
