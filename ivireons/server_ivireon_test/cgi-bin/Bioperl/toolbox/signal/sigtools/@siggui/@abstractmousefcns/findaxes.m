function hax = findaxes(hObj, hg)
%FINDAXES Find the axes which contains HG

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:29:41 $

% This should be a private method

hax = hg(1);
while ~strcmpi(get(hax, 'type'), 'axes') && hax,
    hax = get(hax, 'Parent');
end

% [EOF]
