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
    fprintf('index(%d), district(%s), RR_sphere(%.4f), RR_spheroid(%.4f), RR_flatland(%.4f), PP_score(%.4f)\n',...
      idx(i),T.dname{idx(i),1},T.RR_sphere(idx(i)),T.RR_spheroid(idx(i)),T.RR_flatland(idx(i)),T.PP_score(idx(i)));
  endfor
  fprintf('state(%s), number of districts(%d)\n',state,length(idx));
  fprintf('PP_score: range([%.4f,%.4f]), mean(%.4f)\n',min(T.PP_score(idx)),max(T.PP_score(idx)),mean(T.PP_score(idx)));
  fprintf('RR_spheroid: range([%.4f,%.4f]), mean(%.4f)\n',min(T.RR_spheroid(idx)),max(T.RR_spheroid(idx)),mean(T.RR_spheroid(idx)));
  fprintf('RR_sphere: range([%.4f,%.4f]), mean(%.4f)\n',min(T.RR_sphere(idx)),max(T.RR_sphere(idx)),mean(T.RR_sphere(idx)));
  fprintf('RR_flatland: range([%.4f,%.4f]), mean(%.4f)\n',min(T.RR_flatland(idx)),max(T.RR_flatland(idx)),mean(T.RR_flatland(idx)));
endfunction
