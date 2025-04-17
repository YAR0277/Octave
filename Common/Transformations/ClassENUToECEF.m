## Copyright (C) 2022 YAR0277
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{retval} =} ClassENUToECEF (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: YAR0277 <YAR0277@DELL-INSPIRON-3>
## Created: 2022-01-04

classdef ClassENUToECEF
  % Class to transform from ENU coordinate frame to ECEF coordinate frame. A point in rectangular 
  % coordinates ENU frame is transformed to a point in rectangular coordinates ECEF frame.
  % The transformation is done wrt the origin of the ENU coordinate frame given in geodetic
  % coordinates.
  properties
##    oLat = 0; % origin latitude [°]
##    oLon = 0; % origin longitue [°]
##    oHgt = 0; % origin height [m]
    oLat % origin latitude [°]
    oLon % origin longitue [°]
    oHgt % origin height [m]
    T    % frame transformation matrix
  endproperties
  
##  properties (Dependent)
##    T
##  endproperties
  
  methods % Public
    function obj = ClassENUToECEF() % c'tor
##      obj.oLat = 0;
##      obj.oLon = 0;
##      obj.oHgt = 0;
  endfunction
  
    function [r] = get.T(this)
      olon = this.oLon;
      olat = this.oLat;
      ohgt = this.oHgt;
      T=[-sind(olon),-sind(olat)*cosd(olon),cosd(olat)*cosd(olon);...
          cosd(olon),-sind(olat)*sind(olon),cosd(olat)*sind(olon);...
          0,cosd(olat),sind(olat)];      
    endfunction
  endmethods
endclassdef
