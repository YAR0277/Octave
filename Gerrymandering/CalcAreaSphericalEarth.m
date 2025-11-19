function [area] = CalcAreaSphericalEarth(maxlon,minlon,maxlat,minlat)
    R = Constant.radius_spherical_earth_km;
    area = R^2*(sind(maxlat)-sind(minlat))*(maxlon-minlon)*(pi/180);
endfunction
