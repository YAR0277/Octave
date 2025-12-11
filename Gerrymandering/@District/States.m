function [] = States(this,col)
  % col is one of the columns of StateTable, usually either 'meanER' or 'meanPP'

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
  meanER = zeros(numStates,1); % mean ER
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
    meanER(k) = mean(T.ER(idx));
    meanPP(k) = mean(T.PP_score(idx));
  endfor
  this.StateTable = table(stateAbbreviation,numDistricts,meanER,meanPP);

  U = this.StateTable; % short-hand
  [~,idx] = sort(U.(col));
  sU = U(idx,:);

  sCol = sU.(col);
  n = size(sU,1);
  for i=1:n
    fprintf('index(%d), state(%s), score(%.4f)\n',i,sU.stateAbbreviation{i,1},sCol(i));
  endfor

endfunction
