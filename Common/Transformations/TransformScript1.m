##https://gis.stackexchange.com/questions/308445/local-enu-point-of-interest-to-ecef
##https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates
##https://en.wikipedia.org/wiki/Geographic_coordinate_conversion#Coordinate_system_conversion

addpath(genpath("../"))

e = Constant.e;
a = Constant.a;
b = Constant.b;

rlat = 38.950473;
rlon =-77.3893;
rh = 148;
T=[-sind(rlon),-sind(rlat)*cosd(rlon),cosd(rlat)*cosd(rlon);...
    cosd(rlon),-sind(rlat)*sind(rlon),cosd(rlat)*sind(rlon);...
    0,cosd(rlat),sind(rlat)];
    
N=a/(sqrt(1-e^2*sind(rlat)^2));
radarECEF =[ (N+rh)*cosd(rlat)*cosd(rlon);...
      (N+rh)*cosd(rlat)*sind(rlon);...
      (N*(1-e^2)+rh)*sind(rlat)];
rho = 5000;
azi = 270;
alt = 200;
ptENU=[rho.*sind(azi);rho.*cosd(azi);alt-rh];
ptECEF=T*ptENU+radarECEF;
p=sqrt(ptECEF(1)^2+ptECEF(2)^2);
ptLon=2*atan2d(ptECEF(2),ptECEF(1)+p);
theta=atan2d(ptECEF(3)*a,p*b);
eprime=sqrt((a^2-b^2)/b^2);
ptLat=atan2d(ptECEF(3)+eprime^2*b*sind(theta)^3,p-e^2*a*cosd(theta)^3);
N=a^2/(sqrt(a^2*cosd(ptLat)^2+b^2*sind(ptLat)^2));
ptH=(p/cosd(ptLat))-N;