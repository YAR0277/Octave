function [] = RemoveState(this,state)

  T = this.DistrictTable; % short-hand

  this.DistrictTableBackup = T; % backup

  n = size(T,1);
  idx = NaN(n,1);
  count = 1;

  for i=1:n
    theStr = char(T.dname{i,1});
    if length(theStr) < 2
      continue;
    endif

    if strcmp(state,substr(theStr,1,2))
      idx(count)=i;
      count = count + 1;
    endif
  endfor
  idx(isnan(idx)) = [];

  T(idx,:) = [];
  this.DistrictTable = T;
  fprintf('Data from state (%s) removed from District Table\n',state);
endfunction
