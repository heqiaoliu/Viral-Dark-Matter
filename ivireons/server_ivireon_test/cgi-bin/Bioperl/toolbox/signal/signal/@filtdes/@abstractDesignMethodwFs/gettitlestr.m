function str = gettitlestr(d)
%GETTITLESTR Returns the title for GENMCODE

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2006/11/19 21:45:13 $

% This should be private

str = sprintf('%% %s %s filter designed using the %s function.', ...
    get(d, 'Tag'), ...
    get(d, 'ResponseType'), ...
    upper(designfunction(d.responsetypespecs, d)));
    
% [EOF]
