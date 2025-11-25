function [area] = CalcAreaSpheroidEarth(~,maxlon,minlon,maxlat,minlat)
    a = Constant.radius_equatorial_earth_km;
    b = Constant.radius_polar_earth_km;
    e1 = GeoUtil.e1(); % first eccentricity earth
    e2 = GeoUtil.e2(); % second eccentricity earth
    f = @(t) secd(t)*tand(t) + log(abs(secd(t)+tand(t)));
    y = @(t) GeoUtil.RN(t)*(1 - e1^2)*sind(t);
    p = @(t) atand((e2/b)*y(t));
    % endpoints
    u1 = p(minlat);
    u2 = p(maxlat);
    area = ((a*b)/(2*e2))*(f(u2)-f(u1))*(maxlon-minlon)*(pi/180);
endfunction
