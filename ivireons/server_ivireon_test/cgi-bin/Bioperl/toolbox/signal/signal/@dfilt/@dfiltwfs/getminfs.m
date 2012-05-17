function [fs, xunits] = getminfs(hObj)
%MAXFS Returns the maximum fs

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/05/07 19:56:24 $

fs = get(hObj, 'Fs');

if iscell(fs),
    fs = min([fs{:}]);
end

if nargout > 1,
    if isempty(fs),
        xunits = 'rad/sample';
    else
        [fs, m, xunits] = engunits(fs);
        xunits          = [xunits 'Hz'];
    end
end

% [EOF]
