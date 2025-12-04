function [lats,lons] = GetCoordinate(~,c0)
  % c0 is single long cell string "lon,lat,alt,lon,lat,alt,..."

    c1 = strrep(c0,",0", ","); % delete alt coordinate since it's always zero, "0,".
    c2 = substr(c1,1,length(c1)-1); % delete trailing comma

    a1 = strsplit(c2,","); % single string -> string array
    a2 = str2double(a1); % string array -> double array

    lons = a2(1:2:end); % odds are the lons
    lats = a2(2:2:end); % evens are the lats
endfunction
