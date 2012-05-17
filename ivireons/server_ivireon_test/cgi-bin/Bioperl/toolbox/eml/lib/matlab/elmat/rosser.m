function R = rosser(classname)
%Embedded MATLAB Library Function

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

if nargin < 1
    classname = 'double';
end
R  = cast( ...
    [611,  196, -192,  407,   -8,  -52,  -49,   29;
     196,  899,  113, -192,  -71,  -43,   -8,  -44;
    -192,  113,  899,  196,   61,   49,    8,   52;
     407, -192,  196,  611,    8,   44,   59,  -23;
      -8,  -71,   61,    8,  411, -599,  208,  208;
     -52,  -43,   49,   44, -599,  411,  208,  208;
     -49,   -8,    8,   59,  208,  208,   99, -911;
      29,  -44,   52,  -23,  208,  208, -911,   99], ...
    classname);