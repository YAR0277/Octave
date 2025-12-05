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
    CsvDistrictTable
    CsvFileDistrict
    CsvTable
	  DataFolder
    DistrictTable % the main district table
    DistrictTableBackup
    Project % an instance of the Projection class
    XmlFile
  endproperties

  methods % Public
    function [obj] = District()

      pkg load io;
      pkg load tablicious;

      addpath(genpath('../Common/')); % Constant
      addpath(genpath('../Geodesy/')); % GeoUtil

      obj.CsvDistrictTable = 'DistrictTable.csv';
      obj.CsvFileDistrict = 'NTAD_Congressional_Districts_abridged.csv';
      obj.CsvTable = [];
      obj.DataFolder = 'C:\Users\drdav\data\districts\';
      obj.DistrictTable = [];
      obj.DistrictTableBackup = [];
      obj.Project = Projection();
      obj.XmlFile = 'NTAD_Congressional_Districts.xml'; % 'AK00.xml'
    endfunction

    function [r] = get.Eccentricity(this)
      r = this.Project.Eccentricity;
    endfunction

    function [] = set.Eccentricity(this,e)
      this.Project.Eccentricity = e;
    endfunction

    []  = Bottom(this,nr,col);
    [r] = CalcAreaFlatland(this,minlon,maxlon,minlat,maxlat);
    [p] = CalcPerimeter(~,x,y);
    [dname,PD,PP_score] = CalcPolsbyPopper(this);
    []  = Generate(this);
    []  = RemoveState(this,state);
    []  = State(this,state);
    []  = Stats(this);
    []  = Top(this,nr,col);
    []  = Write2Csv(this);
  endmethods

  methods (Access = 'private')
    [r] = CalcAreaSphericalEarth(this,minlon,maxlon,minlat,maxlat);
    [r] = CalcAreaSpheroidEarth(this,minlon,maxlon,minlat,maxlat);
    [r] = CheckDistrictName(this,districtName);
    [lats,lons] = GetCoordinate(~,c0);
    [maxlon,minlon,maxlat,minlat] = GetMaxMinCoordinate(~,c0);
    [r] = LookupDistrictArea(this,districtName);
    [r] = LookupDistrictName(this,districtName);
    [T] = ReadCsvIntoTable(this,filename);
  endmethods
endclassdef
