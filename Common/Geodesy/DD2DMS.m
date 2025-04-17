function [deg,min,sec] = DD2DMS(decimalDegrees)
  
% Purpose : to convert decimal degrees (DD) to degrees, minutes, seconds (DMS)
% Example : -8.151278° -> -8°9'10"
% Call    :[deg,min,sec]=DD2DMS(-8.151278)
  
    val = abs(decimalDegrees);
    deg = floor(val);
    val = (val - deg)*60;
    min = floor(val);
    sec = (val - min)*60;
    
    if (decimalDegrees < 0)
      if (deg ~= 0)
        deg = -deg;
      elseif (min ~= 0)
        min = -min;
      else
        sec = -sec;
      endif
    endif
endfunction

        

