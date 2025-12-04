function [dname,PD,PP_score] = CalcPolsbyPopper(this)
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
  AD = zeros(numPlacemark,1); % AD = area of district
  PD = zeros(numPlacemark,1); % PD = perimeter of district
  PP_score = zeros(numPlacemark,1);

  for i=0:numPlacemark-1
    name = placemark.item(i).getElementsByTagName("name");
    districtName = name.item(0).getTextContent();

    if this.CheckDistrictName(districtName) == 0
      fprintf('Invalid distrct (%s)\n', districtName);
      continue;
    endif

    lat = [];
    lon = [];
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

      tmpAD = this.LookupDistrictArea(districtName);
      tmpName = this.LookupDistrictName(districtName);
      if length(char(tmpName)) < 4 || tmpAD == 0
        continue;
      endif
      dname(i+1) = tmpName;
      AD(i+1) = tmpAD;
      [x,y] = this.Project.EqualEarth(lat,lon);
      PD(i+1) = this.CalcPerimeter(x,y);
      PP_score(i+1) = 4*pi*(AD(i+1)/PD(i+1)^2);

    else
      coordinates = placemark.item(i).getElementsByTagName("coordinates");
      numCoordinates = coordinates.getLength();
      if numCoordinates == 1
        c0 = coordinates.item(0).getTextContent(); % get coordinates lon,lat,alt,... as single long cell string
        [lat,lon] = this.GetCoordinate(c0);

        tmpAD = this.LookupDistrictArea(districtName);
        tmpName = this.LookupDistrictName(districtName);
        if length(char(tmpName)) < 4 || tmpAD == 0
          continue;
        endif
        dname(i+1) = tmpName;
        AD(i+1) = tmpAD;
        [x,y] = this.Project.EqualEarth(lat,lon);
        PD(i+1) = this.CalcPerimeter(x,y);
        PP_score(i+1) = 4*pi*(AD(i+1)/PD(i+1)^2);
      endif
    endif
  endfor

  % remove entries with PD == 0
  ix = (AD == 0 || PD == 0);
  dname(ix) = [];
  AD(ix) = [];
  PD(ix) = [];
  PP_score(ix) = [];

  toc
endfunction
