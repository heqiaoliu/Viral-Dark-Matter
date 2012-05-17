function [success, exception] = validateMap(this, map)
%VALIDATEMAP Validate the map

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 16:05:45 $

success = true;
exception = [];

if nargin < 2
    map = get(this, 'map');
end

% Only check if this is an intensity datasource
% Allow empty colormaps -- it's up to the caller to handle them
%
if size(map,2) ~= 3
    success = false;
    [msg, id] = uiscopes.message('InvalidColormapDimensions');
    exception = MException(id, msg);
elseif ~isreal(map) || issparse(map) || ~isnumeric(map)
    success = false;
    [msg, id] = uiscopes.message('ColormapNotReal');
    exception = MException(id, msg);
elseif any(map(:)<0) || any(map(:)>1)
    success = false;
    [msg, id] = uiscopes.message('InvalidColormapRange');
    exception = MException(id, msg);
end

% [EOF]
