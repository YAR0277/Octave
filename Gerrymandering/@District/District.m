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
    StateTable % filled by States.m
    XmlFile
  endproperties

  methods % Public
    function [obj] = District()

      pkg load io;
      pkg load tablicious;

      addpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'Common')); % Constant
      addpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'Common')); % GeoUtil

      obj.CsvDistrictTable = 'DistrictTable.csv';
      obj.CsvFileDistrict = 'NTAD_Congressional_Districts_abridged.csv';%'VA_Proposed_Districts.csv';
      obj.CsvTable = [];
      obj.DistrictTable = [];
      obj.DistrictTableBackup = [];
      obj.Project = Projection();
      obj.StateTable = [];
      obj.XmlFile = 'NTAD_Congressional_Districts.xml';%'VA_Proposed_Districts.xml';%'AK00.xml'
      obj.SetDataFolder;
    endfunction

    function [r] = get.Eccentricity(this)
      r = this.Project.Eccentricity;
    endfunction

    function [] = set.Eccentricity(this,e)
      this.Project.Eccentricity = e;
    endfunction

    []  = Bottom(this,nr,col);
    [p] = CalcPerimeter(~,x,y);
    [dname,PD,PP_score] = CalcPolsbyPopper(this);
    []  = CmpAreaFlatland(this);
    []  = CmpAreaSphere(this);
    []  = GenDistrictTable(this);
    []  = GenStateTable(this);
    []  = RemoveState(this,state);
    []  = State(this,state);
    []  = States(this,col);
    []  = Stats(this);
    []  = Top(this,nr,col);
    []  = Write2Csv(this);
  endmethods

  methods (Access = 'private')
    [r] = CheckDistrictName(this,districtName);
    [lats,lons] = GetCoordinate(~,c0);
    [maxlon,minlon,maxlat,minlat] = GetMaxMinCoordinate(~,c0);
    [r] = LookupDistrictArea(this,districtName);
    [r] = LookupDistrictName(this,districtName);
    [T] = ReadCsvIntoTable(this,filename);

    function [] = SetDataFolder(this)
      if ispc
        this.DataFolder = 'C:\Users\drdav\data\districts\';
      else
        this.DataFolder = '/home/david/data/districts';
      endif
    endfunction
  endmethods
endclassdef
