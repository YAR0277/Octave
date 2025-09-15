function [decimalDegrees] = DMS2DD(deg, min, sec)
  
% Purpose : to convert degrees, minutes, seconds (DMS) to decimal degrees (DD) 
% Example : -8°9'10" -> -8.151278°
% Call    :[decimalDegrees]=DD2DMS(-8,9,10)  

  if (deg < 0 || min < 0 || sec < 0)
    sign = -1;
  else
    sign = 1;
  endif
  
  decimalDegrees = sign*(abs(deg) + abs(min)/60 + abs(sec)/3600);
endfunction    

