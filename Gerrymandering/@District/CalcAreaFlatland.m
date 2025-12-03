function [area] = CalcAreaFlatland(this,minlon,maxlon,minlat,maxlat)
  lat = [minlat,maxlat];
  lon = [minlon,maxlon];
  [x,y] = this.Project.EqualEarth(lat,lon);
  area = diff(x)*diff(y);
endfunction
