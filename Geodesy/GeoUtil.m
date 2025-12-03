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

    function [r] = authalic_latitude(e,lat)
      % [r] = authalic_latitude(lat), where lat in [deg], r in [rad]
      if (e == 0)
        q_p = 1;
        g = @(t) ( sind(t) );
      else
        q_p = ( (1-e^2) * ( (1/(1 - e^2)) - (1/(2*e))*log((1-e)/(1+e)) ) );
        g = @(t) ( (1-e^2)*( (sind(t)./(1 - e^2*sind(t).^2)) - (1/(2*e)).*log((1-e.*sind(t))./(1+e.*sind(t))) ) );
      endif
      q = g(lat);
      r = asin(q./q_p);
    endfunction

    function [r] = authalic_radius_km(e)
      % authalic radius in [km]
      if (e == 0)
        q_p = 1;
      else
        q_p = ( (1-e^2) * ( (1/(1 - e^2)) - (1/(2*e))*log((1-e)/(1+e)) ) );
      endif
      a = Constant.radius_equatorial_earth_km;
      r = a*sqrt(q_p/2);
    endfunction

    function [r] = Deg2Rad(x)
      r = (pi/180).*x;
    endfunction

    function [r] = Rad2Deg(x)
      r = (180/pi).*x;
    endfunction

    function [d,m,s] = DD2DMS(dd)
      % [d,m,s] = DD2DMS(dd), convert decimal degrees (DD) to degrees, minutes, seconds (DMS), ex -8.151278 -> -8°9'10".
      val = abs(dd);
      d = floor(val);
      val = (val - d)*60;
      m = floor(val);
      s = (val - m)*60;

      if (dd < 0)
        if (d ~= 0)
          d = -d;
        elseif (m ~= 0)
          m = -m;
        else
          s = -s;
        endif
      endif
    endfunction

    function [dd] = DMS2DD(d,m,s)
      % [dd] = DMS2DD(d,m,s), convert degrees, minutes, seconds (DMS) to decimal degrees (DD), ex. -8°9'10" -> -8.151278.
      if (d < 0 || m < 0 || s < 0)
        sign = -1;
      else
        sign = 1;
      endif
      dd = sign*(abs(d) + abs(m)/60 + abs(s)/3600);
    endfunction

  endmethods
endclassdef
