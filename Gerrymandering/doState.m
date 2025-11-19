function [] = doState(T,state)
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

  for i=1:length(idx)
    fprintf('index(%d), district(%s), RR(%.4f)\n',idx(i),T.dname{idx(i),1},T.RR(idx(i)));
  endfor
  fprintf('number(%d), district(%s), range([%.4f,%.4f]), mean(%.4f)\n',length(idx),state,min(T.RR(idx)),max(T.RR(idx)),mean(T.RR(idx)));
endfunction
