function [] = Stats(this)
  T = this.DistrictTable; % short-hand

  fprintf('Distric Area:mean(%.4f), std(%.4f)\n',mean(T.AD),std(T.AD));
  fprintf('Distric Perimeter:mean(%.4f), std(%.4f)\n',mean(T.PD),std(T.PD));

  fprintf('Envelope Area (sphere):mean(%.4f), std(%.4f)\n',mean(T.AE_sphere),std(T.AE_sphere));
  fprintf('Envelope Area (spheroid):mean(%.4f), std(%.4f)\n',mean(T.AE_spheroid),std(T.AE_spheroid));
  fprintf('Envelope Area (flatland):mean(%.4f), std(%.4f)\n',mean(T.AE_flatland),std(T.AE_flatland));

  fprintf('Envelope Ratio (sphere):mean(%.4f), std(%.4f)\n',mean(T.ER_sphere),std(T.ER_sphere));
  fprintf('Envelope Ratio (spheroid):mean(%.4f), std(%.4f)\n',mean(T.ER_spheroid),std(T.ER_spheroid));
  fprintf('Envelope Ratio (flatland):mean(%.4f), std(%.4f)\n',mean(T.ER_flatland),std(T.ER_flatland));
  fprintf('PP_score:mean(%.4f), std(%.4f)\n',mean(T.PP_score),std(T.PP_score));

  % https://www.mathworks.com/matlabcentral/answers/197264-plotting-multiple-histograms-in-one-figure
  hist(T.RR_spheroid,50,'facecolor',Color.Brown,'facealpha',.5,'edgecolor','none');
  hold on;
  hist(T.PP_score,50,'facecolor',Color.Magenta,'facealpha',.5,'edgecolor','none');
  box off;
  axis tight;
  legend('ER','PP','location','northeast');
  legend boxoff;
endfunction
