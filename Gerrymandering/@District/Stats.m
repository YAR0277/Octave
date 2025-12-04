function [] = Stats(this)
  T = this.DistrictTable; % short-hand

  fprintf('Distric Area:mean(%.4f), std(%.4f)\n',mean(T.AD),std(T.AD));
  fprintf('Distric Perimeter:mean(%.4f), std(%.4f)\n',mean(T.PD),std(T.PD));

  fprintf('District Area (sphere):mean(%.4f), std(%.4f)\n',mean(T.AR_sphere),std(T.AR_sphere));
  fprintf('District Area (spheroid):mean(%.4f), std(%.4f)\n',mean(T.AR_spheroid),std(T.AR_spheroid));
  fprintf('District Area (flatland):mean(%.4f), std(%.4f)\n',mean(T.AR_flatland),std(T.AR_flatland));

  fprintf('RR_score (sphere):mean(%.4f), std(%.4f)\n',mean(T.RR_sphere),std(T.RR_sphere));
  fprintf('RR_score (spheroid):mean(%.4f), std(%.4f)\n',mean(T.RR_spheroid),std(T.RR_spheroid));
  fprintf('RR_score (flatland):mean(%.4f), std(%.4f)\n',mean(T.RR_flatland),std(T.RR_flatland));
  fprintf('PP_score:mean(%.4f), std(%.4f)\n',mean(T.PP_score),std(T.PP_score));

  % https://www.mathworks.com/matlabcentral/answers/197264-plotting-multiple-histograms-in-one-figure
  hist(T.RR_spheroid,50,'facecolor',Color.Brown,'facealpha',.5,'edgecolor','none');
  hold on;
  hist(T.PP_score,50,'facecolor',Color.Magenta,'facealpha',.5,'edgecolor','none');
  box off;
  axis tight;
  legend('RR Score','PP Score','location','northeast');
  legend boxoff;
endfunction
