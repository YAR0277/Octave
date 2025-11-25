classdef District < handle
% compactness of U.S. Congressional Districts
%
% Data:
% 1. download csv file and kml file from [1].
% 2. rename kml file to xml file and use 'xmlread' in Generate method.
% 3. delete all but columns from csv file : OBJECTID,ALAND,AWATER,INTPTLAT,INTPTLON,OFFICE_ID,PARTY
%     ALAND is the land area in [m^2], OFFICE_ID is the congressional district abbreviation, e.g. "AK00,NC09,..."
%
% References:
% [1] https://hub.arcgis.com/datasets/usdot::congressional-districts/explore?location=34.901819%2C-84.282322%2C5.99
% [2] https://www.tutorialspoint.com/xerces/xerces_dom_parse_document.htm

  properties
    CsvFileDistrict
    CsvTable
	  DataFolder
    DistrictTable % the main district table
    XmlFile
  endproperties

  methods % Public
    function [obj] = District()

      pkg load io;
      pkg load tablicious;

      addpath(genpath('../Common/')); % Constant
      addpath(genpath('../Geodesy/')); % GeoUtil

      obj.CsvFileDistrict = 'NTAD_Congressional_Districts_abridged.csv';
      obj.CsvTable = [];
      obj.DataFolder = 'C:\Users\drdav\data\districts\';
      obj.DistrictTable = [];
      obj.XmlFile = 'NTAD_Congressional_Districts.xml';
    endfunction

    []  = Best(this,nr);
    []  = Generate(this);
    []  = State(this,state);
    []  = Stats(this);
    []  = Worst(this,nr);
  endmethods

  methods (Access = 'private')
    [r] = CalcAreaRectangularGate(this,maxlon,minlon,maxlat,minlat);
    [r] = CalcAreaSphericalEarth(this,maxlon,minlon,maxlat,minlat);
    [r] = CalcAreaSpheroidEarth(this,maxlon,minlon,maxlat,minlat);
    [r] = CheckDistrictName(this,districtName);
    [maxlon,minlon,maxlat,minlat] = GetMaxMinCoordinate(this,c0);
    [r] = LookupDistrictArea(this,districtName);
    [r] = LookupDistrictName(this,districtName);
    [T] = ReadCsvIntoTable(this,filename);
  endmethods
endclassdef
