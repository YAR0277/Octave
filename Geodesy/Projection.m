classdef Projection < handle
  % projections class
  %
  % references
  % [1] https://shadedrelief.com/ee_proj/EEp_Math_and_Implementation_details_%202019-04-16.pdf
  % [2] https://en.wikipedia.org/wiki/Equal_Earth_projection

  methods (Static = true) % Public

    function [x,y] = EqualEarth(lat,lon)
      % [x,y] = EqualEarth(lat,lon), lat,lon[°], and x,y[km] - flat-space rectangular coordinates
      % an equal-area pseudocylindrical projection, [1],[2]
      A1 = +1.340264;
      A2 = -0.081106;
      A3 = +0.000893;
      A4 = +0.003796;
      M = sqrt(3)/2;
      lon0 = -90.0; % 90°W
      authalicLat = GeoUtil.authalic_latitude(lat); % lat[°], authalicLat[rad]
      paramLat = asin(M*sin(authalicLat)); % paramLat[rad]
      sigma = (A1 + 3*A2*paramLat.^2 + 7*A3*paramLat.^6 + 9*A4*paramLat.^8);
      Factor = (cos(paramLat))./(M.*sigma);
      x = GeoUtil.Deg2Rad(lon-lon0).*Factor;
      y = (A1*paramLat + A2*paramLat.^3 + A3*paramLat.^7 + A4*paramLat.^9);

      authalicRadius = GeoUtil.authalic_radius_km;
      x = authalicRadius*x;
      y = authalicRadius*y;
    endfunction

  endmethods
endclassdef
