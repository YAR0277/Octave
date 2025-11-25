function [area] = CalcAreaRectangularGate(~,maxlon,minlon,maxlat,minlat)
  lat = mean([minlat,maxlat]);
  dx = GeoUtil.RN(lat)*cosd(lat)*(maxlon-minlon)*(pi/180);
  dy = GeoUtil.RM(lat)*(maxlat-minlat)*(pi/180);
  area = dx*dy;
endfunction
