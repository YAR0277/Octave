function [lat_dms,lon_dms] = DD2DMSLatLon(decimalDegreesLat,decimalDegreesLon)

% Purpose : to convert lat,lon in decimal degrees (DD) to degrees, minutes, seconds (DMS)
% Example : 39.098491°,-77.549918° -> 39°5'54.57",77°32',59.71"
% Call    :[lat_dms,lon_dms]=DD2DMSLatLon(39.098491,-77.549918)

  [lat_deg,lat_min,lat_sec] = DD2DMS(decimalDegreesLat);  
  [lon_deg,lon_min,lon_sec] = DD2DMS(decimalDegreesLon); 
 
  lat_dms = strcat(num2str(lat_deg),"deg",num2str(lat_min),"'",num2str(lat_sec),"''");
  lon_dms = strcat(num2str(lon_deg),"deg",num2str(lon_min),"'",num2str(lon_sec),"''");
  
endfunction
        

