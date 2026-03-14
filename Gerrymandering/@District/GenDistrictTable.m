function [] = GenDistrictTable(this)
  tic

  if ispc
    javaaddpath("C:\\Octave\\xerces\\xerces-2_11_0\\xml-apis.jar");
    javaaddpath("C:\\Octave\\xerces\\xerces-2_11_0\\xercesImpl.jar");
  endif

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
  midlat = +1e3*ones(numPlacemark,1);
  AD = zeros(numPlacemark,1); % AD = area of district
  PD = zeros(numPlacemark,1); % PD = perimeter of district
  AE = zeros(numPlacemark,1); % AE = area of envelope
  AE_sphere = zeros(numPlacemark,1);
  AE_flatland = zeros(numPlacemark,1);
  AE_girard = zeros(numPlacemark,1);
  GE_score = zeros(numPlacemark,1); % geodetic envelope score
  GE_sphere = zeros(numPlacemark,1);
  GE_flatland = zeros(numPlacemark,1);
  PP_score = zeros(numPlacemark,1); % Polsby-Popper score

  for i=0:numPlacemark-1
    name = placemark.item(i).getElementsByTagName("name");
    districtName = name.item(0).getTextContent();

    if this.CheckDistrictName(districtName) == 0
      fprintf('Invalid district (%s)\n', districtName);
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
      midlat(i+1) = median([min(lat),max(lat)]);

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
      AE(i+1) = envelope.CalcArea();
      AE_sphere(i+1) = envelope.CalcAreaSphere();
      AE_flatland(i+1) = envelope.CalcAreaFlatland();
      AE_girard(i+1) = envelope.CalcAreaGirard();
      GE_score(i+1) = AD(i+1)/AE(i+1);
      GE_sphere(i+1) = AD(i+1)/AE_sphere(i+1);
      GE_flatland(i+1) = AD(i+1)/AE_flatland(i+1);
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
        midlat(i+1) = median([min(lat),max(lat)]);

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
        AE(i+1) = envelope.CalcArea();
        AE_sphere(i+1) = envelope.CalcAreaSphere();
        AE_flatland(i+1) = envelope.CalcAreaFlatland();
        AE_girard(i+1) = envelope.CalcAreaGirard();
        GE_score(i+1) = AD(i+1)/AE(i+1);
        GE_sphere(i+1) = AD(i+1)/AE_sphere(i+1);
        GE_flatland(i+1) = AD(i+1)/AE_flatland(i+1);
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
  midlat(ix) = [];
  AD(ix) = [];
  PD(ix) = [];
  AE(ix) = [];
  AE_sphere(ix) = [];
  AE_flatland(ix) = [];
  AE_girard(ix) = [];
  GE_score(ix) = [];
  GE_sphere(ix) = [];
  GE_flatland(ix) = [];
  PP_score(ix) = [];

  this.DistrictTable = table(dname,minlon,maxlon,minlat,maxlat,midlat,AD,PD,AE,AE_sphere,AE_flatland,AE_girard,GE_score,GE_sphere,GE_flatland,PP_score);
  toc
endfunction
