function [] = State(this,state)

  T = this.DistrictTable; % short-hand

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
    fprintf('index(%d), district(%s), GE_score(%.4f), GE_sphere(%.4f), GE_flatland(%.4f), PP_score(%.4f)\n',...
      idx(i),T.dname{idx(i),1},T.GE_score(idx(i)),T.GE_sphere(idx(i)),T.GE_flatland(idx(i)),T.PP_score(idx(i)));
  endfor
  fprintf('state(%s), number of districts(%d)\n',state,length(idx));
  fprintf('PP: range([%.4f,%.4f]), mean(%.4f)\n',min(T.PP_score(idx)),max(T.PP_score(idx)),mean(T.PP_score(idx)));
  fprintf('GE: range([%.4f,%.4f]), mean(%.4f)\n',min(T.GE_score(idx)),max(T.GE_score(idx)),mean(T.GE_score(idx)));
  fprintf('GE_sphere: range([%.4f,%.4f]), mean(%.4f)\n',min(T.GE_sphere(idx)),max(T.GE_sphere(idx)),mean(T.GE_sphere(idx)));
  fprintf('GE_flatland: range([%.4f,%.4f]), mean(%.4f)\n',min(T.GE_flatland(idx)),max(T.GE_flatland(idx)),mean(T.GE_flatland(idx)));
endfunction
