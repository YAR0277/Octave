function [area] = CalcAreaSphericalEarth(~,minlon,maxlon,minlat,maxlat)
    R = Constant.radius_spherical_earth_km;
    area = R^2*(sind(maxlat)-sind(minlat))*(maxlon-minlon)*(pi/180);
endfunction
