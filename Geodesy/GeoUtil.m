classdef GeoUtil < handle
  % geodesy utilities class

  methods (Static = true) % Public

    function [r] = e1()
      % first eccentricity of the earth
      a = Constant.radius_equatorial_earth_km;
      b = Constant.radius_polar_earth_km;
      r = (a^2 - b^2)/(a^2);
      r = sqrt(r);
    endfunction

    function [r] = e2()
      % second eccentricity of the earth
      a = Constant.radius_equatorial_earth_km;
      b = Constant.radius_polar_earth_km;
      r = (a^2 - b^2)/(b^2);
      r = sqrt(r);
    endfunction

    function [r] = RN(lat)
      % normal radius
      a = Constant.radius_equatorial_earth_km;
      e = GeoUtil.e1();
      f = @(t) (a) ./ ((1 - e^2.*sind(t).^2).^(1/2));
      r = f(lat);
    endfunction

    function [r] = RM(lat)
      % normal radius
      a = Constant.radius_equatorial_earth_km;
      e = GeoUtil.e1();
      f = @(t) (a.*(1-e^2)) ./ ((1 - e^2.*sind(t).^2).^(3/2));
      r = f(lat);
    endfunction

  endmethods
endclassdef
