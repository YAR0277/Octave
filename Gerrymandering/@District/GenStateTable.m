function [] = GenStateTable(this)
  tic

  T = this.DistrictTable; % short-hand
  n = size(T,1);

  stateNames = ...
    {"AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",...
     "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",...
     "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",...
     "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",...
     "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"};

  numStates = length(stateNames);
  stateAbbreviation = cell(numStates,1); % state abbreviation
  numDistricts = zeros(numStates,1); % number of districts
  meanGE = zeros(numStates,1); % mean GE
  meanPP = zeros(numStates,1); % mean PP

  for k=1:numStates
    state = stateNames{k};
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
    stateAbbreviation(k) = state;
    numDistricts(k) = length(idx);
    meanGE(k) = mean(T.GE_score(idx));
    meanPP(k) = mean(T.PP_score(idx));
  endfor
  this.StateTable = table(stateAbbreviation,numDistricts,meanGE,meanPP);

  toc
endfunction
