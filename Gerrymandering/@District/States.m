function [] = States(this,col)
  % col is one of the columns of StateTable, usually either 'meanGE' or 'meanPP'

  U = this.StateTable; % short-hand
  [~,idx] = sort(U.(col));
  sU = U(idx,:);

  sCol = sU.(col);
  n = size(sU,1);
  for i=1:n
    fprintf('index(%d), state(%s), numDistricts(%d), score(%.4f)\n',i,sU.stateAbbreviation{i,1},sU.numDistricts(i),sCol(i));
  endfor

endfunction
