function str = gettitlestr(d)
%GETTITLESTR Returns the title for GENMCODE

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/04 18:14:05 $

% This should be private

str = sprintf('%% %s filter designed using the %s function.', ...
    get(d, 'Tag'), ...
    upper(designfunction(d)));

% [EOF]
