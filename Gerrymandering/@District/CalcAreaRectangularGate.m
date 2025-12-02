function [area] = CalcAreaRectangularGate(~,maxlon,minlon,maxlat,minlat)
  lat = [minlat,maxlat];
  lon = [minlon,maxlon];
  [x,y] = Projection.EqualEarth(lat,lon);
  area = diff(x)*diff(y);
endfunction
