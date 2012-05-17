function specs = getspecs(hObj)
%GETSPECS Returns the specs

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 22:53:03 $

props = find(hObj.classhandle.properties, 'Description', 'spec');
specs = get(props, 'Name');

% [EOF]
