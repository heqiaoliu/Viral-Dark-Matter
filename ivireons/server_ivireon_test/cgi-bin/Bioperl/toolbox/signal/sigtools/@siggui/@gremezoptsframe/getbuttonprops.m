function [props, descs] = getbuttonprops(h)
%GETBUTTONPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:42:50 $

[props, descs] = abstract_getbuttonprops(h);

dp = get(h, 'DisabledProps');

for idx = 1:length(dp)
    indx = strcmpi(dp(idx), props);
    if ~isempty(indx),
        props(indx) = [];
        descs(indx) = [];
    end
end

% [EOF]
