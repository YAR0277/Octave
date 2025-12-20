classdef GeoUtil < handle
  % geodesy utilities class

  % references
  % [1] Earth-Referenced Aircraft Navigation and Surveillance Analysis, Volpe
  %
  methods (Static = true) % Public

    function [r] = CalcAzimuth(p,q)
      % find azimuth/heading angle (°) w.r.t. North Pole, -180 < r <= 180.
      de = q(1)-p(1); % delta East
      dn = q(2)-p(2); % delat North
      r = atan2(de,dn);
      r = GeoUtil.Rad2Deg(r);
    endfunction

    function [psiBA,psiAB] = CalcAzimuthAngles(A,B)
      % find azimuth angles at A and B of the great circle arc connecting the two points,[1].
      if ~isstruct(A) || ~isstruct(B)
        return; % return if A,B are not structs
      endif

      if ~all(isfield(A,{'lon','lat'})) || ~all(isfield(B,{'lon','lat'}))
        return; % return if either A,B does not have 'lon', 'lat'
      endif

      % Volpe Eq 86
      psiBA = atan2( cosd(B.lat)*sind(B.lon-A.lon), sind(B.lat)*cosd(A.lat) - cosd(B.lat)*sind(A.lat)*cosd(B.lon-A.lon) );
      % Volpe Eq 87
      psiAB = atan2( cosd(A.lat)*sind(A.lon-B.lon), sind(A.lat)*cosd(B.lat) - cosd(A.lat)*sind(B.lat)*cosd(A.lon-B.lon) );
    endfunction

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

    function [r] = Rlon(lat)
      % [r] = Rlon(lat), where lat in [deg], r in [km]
      r = GeoUtil.RN(lat)*cosd(lat);
    endfunction

    function [r] = Rlat(lat)
      % [r] = Rlat(lat), where lat in [deg], r in [km]
      r = GeoUtil.RM(lat);
    endfunction

    function [r] = RN(lat)
      % normal radius [r] = RN(lat), where lat in [deg], r in [km]
      a = Constant.radius_equatorial_earth_km;
      e = GeoUtil.e1();
      f = @(t) (a) ./ ((1 - e^2.*sind(t).^2).^(1/2));
      r = f(lat);
    endfunction

    function [r] = RM(lat)
      % meridian radius [r] = RM(lat), where lat in [deg], r in [km]
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
