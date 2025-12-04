function [p] = CalcPerimeter(~,x,y)
  p = 0;
  n = length(x);
  for i=1:n-1
    p = p + sqrt((x(i+1)-x(i))^2 + (y(i+1)-y(i))^2);
  endfor
endfunction
