function hPrm = getparameter(hView, tag)
%GETPARAMETER Get a parameter from the winviewer object
%   GETPARAMETER(hView, TAG) Returns the parameter whose tag is TAG from the winviewer object.
%   If the parameter is not available from the winviewer object an empty matrix will be returned.

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:37:21 $

hPrms = get(hView, 'Parameters');

hPrm = [];
if ~isempty(hPrms)
    hPrm = find(hPrms, 'Tag', tag);
end
    
% [EOF]
