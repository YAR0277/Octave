function [] = Bottom(this,nr,col)

  T = this.DistrictTable; % short-hand

  % sort table according to col values
  [~,idx] = sort(T.(col));
  sT = T(idx,:);

  sCol = sT.(col);

  idx = 1:nr;
  for i=1:length(idx)
    fprintf('index(%d), district(%s), RR(%.4f)\n',idx(i),sT.dname{idx(i),1},sCol(idx(i)));
  endfor
  fprintf('number(%d), range([%.4f,%.4f]), mean(%.4f)\n',length(idx),min(sCol(idx)),max(sCol(idx)),mean(sCol(idx)));
endfunction
