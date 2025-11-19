function [] = doStats(T)
  fprintf('mean(%.4f), std(%.4f)\n',mean(T.RR),std(T.RR));
  hist(T.RR);
endfunction
