function [] = doWorst(T,nr)
  idx = 1:nr;
  for i=1:length(idx)
    fprintf('index(%d), district(%s), RR(%.4f)\n',idx(i),T.dname{idx(i),1},T.RR(idx(i)));
  endfor
  fprintf('number(%d), range([%.4f,%.4f]), mean(%.4f)\n',length(idx),min(T.RR(idx)),max(T.RR(idx)),mean(T.RR(idx)));
endfunction
