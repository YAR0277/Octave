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
  AR_sphere = zeros(numPlacemark,1); % AR = area of rectangle
  AR_spheroid = zeros(numPlacemark,1);
  AR_flatland = zeros(numPlacemark,1);
  RR_sphere = zeros(numPlacemark,1); % RR = ratio (wrt) rectangle
  RR_spheroid = zeros(numPlacemark,1);
  RR_flatland = zeros(numPlacemark,1);

  for i=0:numPlacemark-1
    name = placemark.item(i).getElementsByTagName("name");
    districtName = name.item(0).getTextContent();

    if this.CheckDistrictName(districtName) == 0
      fprintf('Invalid distrct (%s)\n', districtName);
      continue;
    endif

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
        [_maxlon,_minlon,_maxlat,_minlat] = this.GetMaxMinCoordinate(c0);
        maxlon(i+1) = max(_maxlon,maxlon(i+1));
        minlon(i+1) = min(_minlon,minlon(i+1));
        maxlat(i+1) = max(_maxlat,maxlat(i+1));
        minlat(i+1) = min(_minlat,minlat(i+1));
      endfor

      tmpAD = this.LookupDistrictArea(districtName);
      tmpName = this.LookupDistrictName(districtName);
      if length(char(tmpName)) < 4 || tmpAD == 0
        continue;
      endif
      dname(i+1) = tmpName;
      AD(i+1) = tmpAD;
      AR_sphere(i+1) = this.CalcAreaSphericalEarth(minlon(i+1),maxlon(i+1),minlat(i+1),maxlat(i+1));
      AR_spheroid(i+1) = this.CalcAreaSpheroidEarth(minlon(i+1),maxlon(i+1),minlat(i+1),maxlat(i+1));
      AR_flatland(i+1) = this.CalcAreaFlatland(minlon(i+1),maxlon(i+1),minlat(i+1),maxlat(i+1));
      RR_sphere(i+1) = AD(i+1)/AR_sphere(i+1);
      RR_spheroid(i+1) = AD(i+1)/AR_spheroid(i+1);
      RR_flatland(i+1) = AD(i+1)/AR_flatland(i+1);

    else
      coordinates = placemark.item(i).getElementsByTagName("coordinates");
      numCoordinates = coordinates.getLength();
      if numCoordinates == 1
        c0 = coordinates.item(0).getTextContent(); % get coordinates lon,lat,alt,... as single long cell string
        [maxlon(i+1),minlon(i+1),maxlat(i+1),minlat(i+1)] = this.GetMaxMinCoordinate(c0);

        tmpAD = this.LookupDistrictArea(districtName);
        tmpName = this.LookupDistrictName(districtName);
        if length(char(tmpName)) < 4 || tmpAD == 0
          continue;
        endif
        dname(i+1) = tmpName;
        AD(i+1) = tmpAD;
        AR_sphere(i+1) = this.CalcAreaSphericalEarth(minlon(i+1),maxlon(i+1),minlat(i+1),maxlat(i+1));
        AR_spheroid(i+1) = this.CalcAreaSpheroidEarth(minlon(i+1),maxlon(i+1),minlat(i+1),maxlat(i+1));
        AR_flatland(i+1) = this.CalcAreaFlatland(minlon(i+1),maxlon(i+1),minlat(i+1),maxlat(i+1));
        RR_sphere(i+1) = AD(i+1)/AR_sphere(i+1);
        RR_spheroid(i+1) = AD(i+1)/AR_spheroid(i+1);
        RR_flatland(i+1) = AD(i+1)/AR_flatland(i+1);
      endif
    endif
  endfor

  % remove entries with RR == 0
  ix = (RR_sphere == 0);
  dname(ix) = [];
  maxlon(ix) = [];
  minlon(ix) = [];
  maxlat(ix) = [];
  minlat(ix) = [];
  AD(ix) = [];
  AR_sphere(ix) = [];
  AR_spheroid(ix) = [];
  AR_flatland(ix) = [];
  RR_sphere(ix) = [];
  RR_spheroid(ix) = [];
  RR_flatland(ix) = [];

  this.DistrictTable = table(dname,minlon,maxlon,minlat,maxlat,AD,AR_sphere,AR_spheroid,AR_flatland,RR_sphere,RR_spheroid,RR_flatland);
  toc
endfunction
