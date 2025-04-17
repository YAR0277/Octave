## Copyright (C) 2022 YAR0277
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} StaticConstant (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: YAR0277 <YAR0277@DELL-INSPIRON-3>
## Created: 2022-01-03

classdef Constant
  properties  (Constant = true)
    e = 0.08181919; % eccentricty
    a = 6378137;    % semi-major axis
    b = 6356752.3142; % semi-minor axis
  endproperties
  methods
##    function Constant(~)
##    end
  endmethods
endclassdef
