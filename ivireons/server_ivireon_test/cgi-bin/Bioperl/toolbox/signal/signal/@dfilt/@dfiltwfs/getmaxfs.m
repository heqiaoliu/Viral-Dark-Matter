function [fs, xunits] = getmaxfs(h)
%MAXFS Returns the maximum fs

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/05/08 06:44:57 $

fs = get(h, 'Fs');

if iscell(fs),
    fs = max([fs{:}]);
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
