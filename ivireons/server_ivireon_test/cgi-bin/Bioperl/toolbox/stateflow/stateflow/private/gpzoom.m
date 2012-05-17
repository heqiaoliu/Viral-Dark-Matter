function gpzoom(obj, light, medium, dark, black)
%GPZOOM( OBJ, LIGHT, MEDIUM, DARK, BLACK )

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.11.2.3 $  $Date: 2008/12/01 08:06:26 $

%Note: Called from zoom.cpp

bmp = get(obj,'cdata');
bmp(light)  = 2;
bmp(medium) = 3;
bmp(dark)   = 4;
bmp(black)  = 0;
set(obj,'cdata',bmp);

