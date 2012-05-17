function str = genmcode(hObj)
%GENMCODE Generate MATLAB code

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2010/01/25 22:53:19 $

% Get the new filter structure name for the filter object.
structure = getconstructor(hObj);

str = sprintf('%s\n%s', ...
    sprintf('%% Convert the filter to the %s structure.', get(hObj, 'TargetStructure')), ...
    sprintf('Hd = convert(Hd, ''%s'');', structure));

% [EOF]
