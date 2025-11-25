function [r] = LookupDistrictName(this,districtName)
  % returns district name
  r = 0;
  ix = find(this.CsvTable.officeid == districtName);
  if ~isempty(ix)
    r = this.CsvTable.officeid(ix);
  endif
endfunction
