function zdata = zlevel(Editor,ObjectType,TargetSize)
%ZLEVEL  Generates Z data for Z layering of objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $ $Date: 2010/04/30 00:37:05 $

switch ObjectType
    case 'constraint'
        zdata = -3;
    case 'backgroundline'
        zdata = -2;
    case 'multimodel'
        zdata = -1;
    case 'curve'
        zdata = 0;
    case 'system'
        zdata = 1;
    case 'compensator'
        zdata = 2;
    case 'clpole'
        zdata = 3;
end

if nargin==3
    zdata = repmat(zdata,TargetSize);
end
    
