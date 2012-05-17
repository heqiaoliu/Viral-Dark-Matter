function y = vec2argfeval(f, x)
%VEC2ARGFEVAL vector to arguments feval

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:58:57 $

% Author(s): Qinghua Zhang

switch numel(x)
  case 1
    y = f(x);
  case 2
    y = f(x(1),x(2));  
  case 3
    y = f(x(1),x(2),x(3)); 
  case 4
    y = f(x(1),x(2),x(3),x(4));    
  case 5
    y = f(x(1),x(2),x(3),x(4),x(5));    
  case 6
    y = f(x(1),x(2),x(3),x(4),x(5),x(6));  
  case 7
    y = f(x(1),x(2),x(3),x(4),x(5),x(6),x(7));
  case 8
    y = f(x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8));  
  case 9
    y = f(x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),x(9));
  case 10
    y = f(x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),x(9),x(10));
  otherwise 
    xc = num2cell(x);
    y = f(xc{:});   
end

% FILE END