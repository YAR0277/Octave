classdef Envelope < handle
  % envelope class
  %
  % references
  % [1] GIS/OGC (Open Geospatial Consortium)

  properties
    Eccentricity  % eccentricity
    MinLon
    MaxLon
    MinLat
    MaxLat
    Project       % an instance of the Projection class
  endproperties

  methods % Public

    function obj = Envelope(p,q)

      if nargin ~= 2
        error('c''tor: Envelope(p,q) where p,q=[lon,lat].');
      endif

      % p,q are WGS-84 coordinates (lon,lat)
      addpath(genpath('../Common/')); % Constant

      obj.Eccentricity = GeoUtil.e1();
      obj.MinLon = min(p(1),q(1));
      obj.MaxLon = max(p(1),q(1));
      obj.MinLat = min(p(2),q(2));
      obj.MaxLat = max(p(2),q(2));
      obj.Project = Projection();
    endfunction

    function [r] = get.Eccentricity(this)
      r = this.Eccentricity;
    endfunction

    function [r] = set.Eccentricity(this,e)
      this.Eccentricity = e;
    endfunction

    function [r] = CalcArea(this)
    % calculates the area of the envelope assuming earth is an oblate spheroid
        a = Constant.radius_equatorial_earth_km;
        b = Constant.radius_polar_earth_km;
        e1 = GeoUtil.e1(); % first eccentricity earth
        e2 = GeoUtil.e2(); % second eccentricity earth
        f = @(t) secd(t)*tand(t) + log(abs(secd(t)+tand(t)));
        y = @(t) GeoUtil.RN(t)*(1 - e1^2)*sind(t);
        p = @(t) atand((e2/b)*y(t));
        % endpoints
        u1 = p(this.MinLat);
        u2 = p(this.MaxLat);
        r = ((a*b)/(2*e2))*(f(u2)-f(u1))*(this.MaxLon-this.MinLon)*(pi/180);
    endfunction

    function [r] = CalcAreaFlatland(this)
    % calculates the area of the envelope after projection onto the xy-plane
      [x1,y1] = this.Project.EqualEarth(this.MinLon,this.MinLat);
      [x2,y1] = this.Project.EqualEarth(this.MaxLon,this.MinLat);
      [x3,y2] = this.Project.EqualEarth(this.MaxLon,this.MaxLat);
      [x4,y2] = this.Project.EqualEarth(this.MinLon,this.MaxLat);
      r = 0.5 * ( -y1*(x2-x1) + x2*(y2-y1) - y1*(x3-x2) - y2*(x4-x3) + x4*(y1-y2) - y2*(x1-x4) );
    endfunction

    function [r] = CalcAreaSphere(this)
    % calculates the area of the envelope assuming earth is a sphere
      R = Constant.radius_spherical_earth_km;
      r = R^2*(sind(this.MaxLat)-sind(this.MinLat))*(this.MaxLon-this.MinLon)*(pi/180);
    endfunction

    function [r] = CalcAreaGirard(this)
      A = struct('lon',this.MinLon,'lat',this.MinLat);
      B = struct('lon',this.MaxLon,'lat',this.MinLat);
      C = struct('lon',this.MaxLon,'lat',this.MaxLat);
      D = struct('lon',this.MinLon,'lat',this.MaxLat);
      [psiBA,psiAB] = GeoUtil.CalcAzimuthAngles(A,B);
      excessLargeTriangle = abs(psiBA) + abs(psiAB) + GeoUtil.Deg2Rad(B.lon-A.lon);
      [psiDC,psiCD] = GeoUtil.CalcAzimuthAngles(C,D);
      excellSmallTriangle = abs(psiDC) + abs(psiCD) + GeoUtil.Deg2Rad(C.lon-D.lon);
      R = Constant.radius_spherical_earth_km;
      r = ((excessLargeTriangle - pi) - (excellSmallTriangle - pi))*R^2; % Girard's formula
    endfunction

    function [x,y] = EqualEarth(this)
    % projects the envelope onto the xy-plane
      [x,y] = this.Project.EqualEarth([this.MinLon,this.MaxLon],[this.MinLat,this.MaxLat]);
    endfunction

  endmethods
endclassdef
