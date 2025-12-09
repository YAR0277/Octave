classdef Projection < handle
  % projections class
  %
  % references
  % [1] https://shadedrelief.com/ee_proj/EEp_Math_and_Implementation_details_%202019-04-16.pdf
  % [2] https://en.wikipedia.org/wiki/Equal_Earth_projection

  properties
    Eccentricity  % eccentricity
    Lon0          % longitude mapped to the y-axis (x=0) in the xy-plane
  endproperties

  methods % Public

    function obj = Projection()

      addpath(genpath('../Common/')); % Constant

      obj.Eccentricity = GeoUtil.e1();
      obj.Lon0 = -90; % 90°W
    endfunction

    function [r] = get.Eccentricity(this)
      r = this.Eccentricity;
    endfunction

    function [r] = set.Eccentricity(this,e)
      this.Eccentricity = e;
    endfunction

    function [r] = get.Lon0(this)
      r = this.Lon0;
    endfunction

    function [r] = set.Lon0(this,lon)
      this.Lon0 = lon;
    endfunction

    function [x,y] = EqualEarth(this,lon,lat)
      % [x,y] = EqualEarth(lon,lat), lon,lat[°], and x,y[km] - flat-space rectangular coordinates
      % an equal-area pseudocylindrical projection, [1],[2]
      A1 = +1.340264;
      A2 = -0.081106;
      A3 = +0.000893;
      A4 = +0.003796;
      M = sqrt(3)/2;
      authalicLat = GeoUtil.authalic_latitude(this.Eccentricity,lat); % lat[°], authalicLat[rad]
      paramLat = asin(M*sin(authalicLat)); % paramLat[rad]
      sigma = (A1 + 3*A2*paramLat.^2 + 7*A3*paramLat.^6 + 9*A4*paramLat.^8);
      Factor = (cos(paramLat))./(M.*sigma);
      x = GeoUtil.Deg2Rad(lon-this.Lon0).*Factor;
      y = (A1*paramLat + A2*paramLat.^3 + A3*paramLat.^7 + A4*paramLat.^9);

      authalicRadius = GeoUtil.authalic_radius_km(this.Eccentricity);
      x = authalicRadius*x;
      y = authalicRadius*y;
    endfunction

  endmethods
endclassdef
