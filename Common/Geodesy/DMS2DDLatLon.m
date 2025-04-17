function [decimalDegreesLat,decimalDegreesLon] = DMS2DDLatLon(lat_deg,lat_min,lat_sec,lon_deg,lon_min,lon_sec)

% Purpose : to convert lat,lon in degrees, minutes, seconds (DMS) to decimal degrees (DD)
% Example : 39°5'54.57",-77°32',59.71" -> 39.098491°,-77.549918°
% Call    :[decimalDegreesLat,decimalDegreesLon]=DMS2DDLatLon(39,5,54,-77,32,59.71)

  [decimalDegreesLat] = DMS2DD(lat_deg,lat_min,lat_sec);  
  [decimalDegreesLon] = DMS2DD(lon_deg,lon_min,lon_sec); 
   
endfunction
        

