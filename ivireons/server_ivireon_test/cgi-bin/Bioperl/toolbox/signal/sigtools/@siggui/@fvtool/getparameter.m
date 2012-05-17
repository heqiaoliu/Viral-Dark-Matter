function hPrm = getparameter(hFVT, tag)
%GETPARAMETER Get a parameter from FVTool
%   GETPARAMETER(hFVT, TAG) Returns the parameter whose tag is TAG from FVTool.
%   If the parameter is not available from FVTool an empty matrix will be returned.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:26:38 $

hPrms = get(hFVT, 'Parameters');

hPrm = [];
if ~isempty(hPrms)
    hPrm = find(hPrms, 'Tag', tag);
end
    
% [EOF]
