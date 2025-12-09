function [] = Generate(this)
  tic

  javaaddpath("C:\\Octave\\xerces\\xml-apis.jar");
  javaaddpath("C:\\Octave\\xerces\\xercesImpl.jar");

  this.CsvTable = this.ReadCsvIntoTable(this.CsvFileDistrict);
  if size(this.CsvTable,1) == 0
    error('Invalid CsvTable, numRows(%d), numCols(%d)\n',size(this.CsvTable,1),size(this.CsvTable,2));
  endif

  dom = xmlread(fullfile(this.DataFolder,this.XmlFile));
  if dom.hasChildNodes() ~= 1
    error('XML file has no child nodes.');
  endif

  placemark = dom.getElementsByTagName("Placemark");
  numPlacemark = placemark.getLength();
  fprintf('%d Placemark nodes ingested.\n', numPlacemark);

  dname = cell(numPlacemark,1);
  maxlon = -1e3*ones(numPlacemark,1);
  minlon = +1e3*ones(numPlacemark,1);
  maxlat = -1e3*ones(numPlacemark,1);
  minlat = +1e3*ones(numPlacemark,1);
  AD = zeros(numPlacemark,1); % AD = area of district
  PD = zeros(numPlacemark,1); % PD = perimeter of district
  AE_sphere = zeros(numPlacemark,1); % AE = area of envelope
  AE_spheroid = zeros(numPlacemark,1);
  AE_flatland = zeros(numPlacemark,1);
  ER_sphere = zeros(numPlacemark,1); % ER = envelope ratio
  ER_spheroid = zeros(numPlacemark,1);
  ER_flatland = zeros(numPlacemark,1);
  PP_score = zeros(numPlacemark,1); % Polsby-Popper score

  for i=0:numPlacemark-1
    name = placemark.item(i).getElementsByTagName("name");
    districtName = name.item(0).getTextContent();

    if this.CheckDistrictName(districtName) == 0
      fprintf('Invalid distrct (%s)\n', districtName);
      continue;
    endif

    lat=[];
    lon=[];

    multiGeometry = placemark.item(i).getElementsByTagName("MultiGeometry");
    numMultiGeometry = multiGeometry.getLength();

    if numMultiGeometry == 1
      polygon = multiGeometry.item(0).getElementsByTagName("Polygon");
      numPolygon = polygon.getLength();

      numCoordinates=0;
      for j=0:numPolygon-1
        coordinates = polygon.item(j).getElementsByTagName("coordinates");
        numCoordinates = numCoordinates + coordinates.getLength();
        c0 = coordinates.item(0).getTextContent();
        [_lat,_lon] = this.GetCoordinate(c0);
        lat = [lat _lat];
        lon = [lon _lon];
      endfor

      maxlon(i+1) = max(lon);
      minlon(i+1) = min(lon);
      maxlat(i+1) = max(lat);
      minlat(i+1) = min(lat);

      tmpAD = this.LookupDistrictArea(districtName);
      tmpName = this.LookupDistrictName(districtName);
      if length(tmpName) < 4 || tmpAD == 0
        continue;
      endif
      dname(i+1) = tmpName;
      AD(i+1) = tmpAD;
      [x,y] = this.Project.EqualEarth(lon,lat);
      PD(i+1) = this.CalcPerimeter(x,y);
      envelope = Envelope([minlon(i+1),minlat(i+1)],[maxlon(i+1),maxlat(i+1)]);
      AE_sphere(i+1) = envelope.CalcAreaSphere();
      AE_spheroid(i+1) = envelope.CalcArea();
      AE_flatland(i+1) = envelope.CalcAreaFlatland();
      ER_sphere(i+1) = AD(i+1)/AE_sphere(i+1);
      ER_spheroid(i+1) = AD(i+1)/AE_spheroid(i+1);
      ER_flatland(i+1) = AD(i+1)/AE_flatland(i+1);
      PP_score(i+1) = 4*pi*(AD(i+1)/PD(i+1)^2);
      clear envelope;

    else
      coordinates = placemark.item(i).getElementsByTagName("coordinates");
      numCoordinates = coordinates.getLength();
      if numCoordinates == 1
        c0 = coordinates.item(0).getTextContent(); % get coordinates lon,lat,alt,... as single long cell string
        [lat,lon] = this.GetCoordinate(c0);
        maxlon(i+1) = max(lon);
        minlon(i+1) = min(lon);
        maxlat(i+1) = max(lat);
        minlat(i+1) = min(lat);

        tmpAD = this.LookupDistrictArea(districtName);
        tmpName = this.LookupDistrictName(districtName);
        if length(tmpName) < 4 || tmpAD == 0
          continue;
        endif
        dname(i+1) = tmpName;
        AD(i+1) = tmpAD;
        [x,y] = this.Project.EqualEarth(lon,lat);
        PD(i+1) = this.CalcPerimeter(x,y);
        envelope = Envelope([minlon(i+1),minlat(i+1)],[maxlon(i+1),maxlat(i+1)]);
        AE_sphere(i+1) = envelope.CalcAreaSphere();
        AE_spheroid(i+1) = envelope.CalcArea();
        AE_flatland(i+1) = envelope.CalcAreaFlatland();
        ER_sphere(i+1) = AD(i+1)/AE_sphere(i+1);
        ER_spheroid(i+1) = AD(i+1)/AE_spheroid(i+1);
        ER_flatland(i+1) = AD(i+1)/AE_flatland(i+1);
        PP_score(i+1) = 4*pi*(AD(i+1)/PD(i+1)^2);
        clear envelope;
      endif
    endif
  endfor

  % remove entries with AD == 0
  ix = (AD == 0);
  dname(ix) = [];
  maxlon(ix) = [];
  minlon(ix) = [];
  maxlat(ix) = [];
  minlat(ix) = [];
  AD(ix) = [];
  PD(ix) = [];
  AE_sphere(ix) = [];
  AE_spheroid(ix) = [];
  AE_flatland(ix) = [];
  ER_sphere(ix) = [];
  ER_spheroid(ix) = [];
  ER_flatland(ix) = [];
  PP_score(ix) = [];

  this.DistrictTable = table(dname,minlon,maxlon,minlat,maxlat,AD,PD,AE_sphere,AE_spheroid,AE_flatland,ER_sphere,ER_spheroid,ER_flatland,PP_score);
  toc
endfunction
