function [] = Stats(this)
  T = this.DistrictTable; % short-hand

  fprintf('AD:mean(%.4f), std(%.4f)\n',mean(T.AD),std(T.AD));

  fprintf('AR_sphere:mean(%.4f), std(%.4f)\n',mean(T.AR_sphere),std(T.AR_sphere));
  fprintf('AR_spheroid:mean(%.4f), std(%.4f)\n',mean(T.AR_spheroid),std(T.AR_spheroid));
  fprintf('AR_gate:mean(%.4f), std(%.4f)\n',mean(T.AR_flatland),std(T.AR_flatland));

  figure;
  hist(T.RR_sphere);
  fprintf('RR_sphere:mean(%.4f), std(%.4f)\n',mean(T.RR_sphere),std(T.RR_sphere));

  figure;
  hist(T.RR_spheroid);
  fprintf('RR_spheroid:mean(%.4f), std(%.4f)\n',mean(T.RR_spheroid),std(T.RR_spheroid));

  figure;
  hist(T.RR_flatland);
  fprintf('RR_gate:mean(%.4f), std(%.4f)\n',mean(T.RR_flatland),std(T.RR_flatland));
endfunction
