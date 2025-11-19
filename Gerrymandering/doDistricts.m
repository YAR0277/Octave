% Data:
% 1. download csv file and kml file from [1].
% 2. rename kml file to xml file and use 'xmlread'
% 3. delete all but columns from csv file : OBJECTID,ALAND,AWATER,INTPTLAT,INTPTLON,OFFICE_ID,PARTY
%     ALAND is the land area in meters squared, OFFICE_ID is the congressional district abbreviation, e.g. "AK00,NC09,..."
%
% References:
% [1] https://hub.arcgis.com/datasets/usdot::congressional-districts/explore?location=34.901819%2C-84.282322%2C5.99
% [2] https://www.tutorialspoint.com/xerces/xerces_dom_parse_document.htm

clear all;

pkg load io;
pkg load tablicious;

addpath(genpath('../Common/')); % Constant
javaaddpath("C:\\Octave\\xerces\\xml-apis.jar");
javaaddpath("C:\\Octave\\xerces\\xercesImpl.jar");

dataFolder = 'C:\Users\drdav\data\districts\';
xmlFile = 'NTAD_Congressional_Districts.xml';
csvFile = 'NTAD_Congressional_Districts_abridged.csv';

tic

try
  csvTable = ReadCsvIntoTable(dataFolder,csvFile);
catch ME
  error('%s at file(%s), name(%s), line(%d), column(%d)\n',...
    ME.message,ME.stack(end).file,ME.stack(end).name,ME.stack(end).line,ME.stack(end).column);
end_try_catch

dom = xmlread(fullfile(dataFolder,xmlFile));
if dom.hasChildNodes() ~= 1
  error('XML file has no child nodes.');
endif

placemark = dom.getElementsByTagName("Placemark");
numPlacemark = placemark.getLength();
fprintf('%d Placemark nodes ingested\n', numPlacemark);

dname = cell(numPlacemark,1);
AD = zeros(numPlacemark,1); % AD = area of district
AR = zeros(numPlacemark,1); % AR = area of rectangle
RR = zeros(numPlacemark,1); % RR = ratio (wrt) rectangle

for i=0:numPlacemark-1
  name = placemark.item(i).getElementsByTagName("name");
  districtName = name.item(0).getTextContent();
  multiGeometry = placemark.item(i).getElementsByTagName("MultiGeometry");
  numMultiGeometry = multiGeometry.getLength();

  if numMultiGeometry == 1
    polygon = multiGeometry.item(0).getElementsByTagName("Polygon");
    numPolygon = polygon.getLength();

    numCoordinates=0;maxlon=-1000;minlon=1000;maxlat=-1000;minlat=1000;
    for j=0:numPolygon-1
      coordinates = polygon.item(j).getElementsByTagName("coordinates");
      numCoordinates = numCoordinates + coordinates.getLength();
      c0 = coordinates.item(0).getTextContent();
      [_maxlon,_minlon,_maxlat,_minlat] = GetMaxMinCoordinate(c0);
      maxlon = max(_maxlon,maxlon);
      minlon = min(_minlon,minlon);
      maxlat = max(_maxlat,maxlat);
      minlat = min(_minlat,minlat);
    endfor

    tmpAR = CalcAreaSphericalEarth(maxlon,minlon,maxlat,minlat);
    tmpAD = LookupDistrictArea(csvTable,districtName);
    tmpName = LookupDistrictName(csvTable,districtName);
    if length(char(tmpName)) < 4 || tmpAD == 0 || tmpAR == 0
      continue;
    endif
    dname(i+1) = tmpName;
    AR(i+1) = tmpAR;
    AD(i+1) = tmpAD;
    RR(i+1) = AD(i+1)/AR(i+1);

  else
    coordinates = placemark.item(i).getElementsByTagName("coordinates");
    numCoordinates = coordinates.getLength();
    if numCoordinates == 1
      c0 = coordinates.item(0).getTextContent(); % get coordinates lon,lat,alt,... as single long cell string
      [maxlon,minlon,maxlat,minlat] = GetMaxMinCoordinate(c0);

      tmpAR = CalcAreaSphericalEarth(maxlon,minlon,maxlat,minlat);
      tmpAD = LookupDistrictArea(csvTable,districtName);
      tmpName = LookupDistrictName(csvTable,districtName);
      if length(char(tmpName)) < 4 || tmpAD == 0 || tmpAR == 0
        continue;
      endif
      dname(i+1) = tmpName;
      AR(i+1) = tmpAR;
      AD(i+1) = tmpAD;
      RR(i+1) = AD(i+1)/AR(i+1);
    endif
  endif
endfor

% remove entries with RR == 0
ix = (RR == 0);
dname(ix) = [];
AR(ix) = [];
AD(ix) = [];
RR(ix) = [];

% sort table according to RR values
T = table(dname,AR,AD,RR);
[~,idx] = sort(T.RR);
sT = T(idx,:);

toc

