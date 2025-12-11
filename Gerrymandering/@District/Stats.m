function [] = Stats(this)
  T = this.DistrictTable; % short-hand

  fprintf('Distric Area:mean(%.4f), std(%.4f)\n',mean(T.AD),std(T.AD));
  fprintf('Distric Perimeter:mean(%.4f), std(%.4f)\n',mean(T.PD),std(T.PD));

  fprintf('EA:mean(%.4f), std(%.4f)\n',mean(T.AE),std(T.AE));
  fprintf('EA (sphere):mean(%.4f), std(%.4f)\n',mean(T.AE_sphere),std(T.AE_sphere));
  fprintf('EA (flatland):mean(%.4f), std(%.4f)\n',mean(T.AE_flatland),std(T.AE_flatland));

  fprintf('GE_score:mean(%.4f), std(%.4f)\n',mean(T.GE_score),std(T.GE_score));
  fprintf('GE_sphere:mean(%.4f), std(%.4f)\n',mean(T.GE_sphere),std(T.GE_sphere));
  fprintf('GE_flatland:mean(%.4f), std(%.4f)\n',mean(T.GE_flatland),std(T.GE_flatland));
  fprintf('PP_score:mean(%.4f), std(%.4f)\n',mean(T.PP_score),std(T.PP_score));

  % https://www.mathworks.com/matlabcentral/answers/197264-plotting-multiple-histograms-in-one-figure
  hist(T.GE_score,50,'facecolor',Color.Brown,'facealpha',.5,'edgecolor','none');
  hold on;
  hist(T.PP_score,50,'facecolor',Color.Magenta,'facealpha',.5,'edgecolor','none');
  box off;
  axis tight;
  legend('GE','PP','location','northeast');
  legend boxoff;
endfunction
