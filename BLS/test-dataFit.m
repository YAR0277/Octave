% Example 1: from BLS data
% Example 2: from A First Course on Time Series (Example 1.1.2)
clear all;

pkg load optim;

addpath(genpath('../Signals/')); % for Sutil

exNr = 1;
switch exNr
  case 1
    bls = Binput('LNS14000000');
    t = bls.timestamp;
    x = bls.value;
    [x_hat,p] = Sutil.GetTrendPoly(t,x,1);

  case 2
    t = [1;2;3;4;5;6;7;8;9;10];
    x = [11.772;12.059;11.200;12.926;14.442;15.694;16.661;16.914;17.176;17.044];
    b0 = [1; 1; 20];
    [x_hat,p] = Sutil.GetTrendLogistic(t,x,b0);

  case 3
    t = [1;2;3;4;5;6;7;8;9;10];
    x = [11.772;12.059;11.200;12.926;14.442;15.694;16.661;16.914;17.176;17.044];
    b0 = [1; 1; -1];
    [x_hat,p] = Sutil.GetTrendMitscherlich(t,x,b0);

  case 4
    t = [1;2;3;4;5;6;7;8;9;10];
    x = [11.772;12.059;11.200;12.926;14.442;15.694;16.661;16.914;17.176;17.044];
    b0 = [1; 1; 0.5];
    [x_hat,p] = Sutil.GetTrendGompertz(t,x,b0);

  case 5
    t = [1;2;3;4;5;6;7;8;9;10];
    x = [0.486;0.973;1.323;1.867;2.568;3.022;3.259;3.663;4.321;5.482];
    b0 = [1; 0.5];
    [x_hat,p,R] = Sutil.GetTrendAllometric(t,x,b0);

  otherwise
endswitch

fprintf('parameters (from highest to lowest order): \n');
p
fprintf('Coefficient of Determination: \n');
Sutil.CoefficientOfDetermination(x,x_hat)

figure;
plot(t,x,'--.',t,x_hat,'--');


