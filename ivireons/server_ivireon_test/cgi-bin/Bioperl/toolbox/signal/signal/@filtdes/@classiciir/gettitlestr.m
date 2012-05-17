function str = gettitlestr(this)
%GETTITLESTR   PreGet function for the 'titlestr' property.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/28 04:35:41 $

str = sprintf('%% %s %s filter designed using FDESIGN.%s.', ...
    get(this, 'Tag'), ...
    get(this, 'ResponseType'), ...
    upper(get(this, 'ResponseType')));

% [EOF]
