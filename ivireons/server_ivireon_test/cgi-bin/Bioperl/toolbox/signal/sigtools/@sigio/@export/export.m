function hXP = export(data)
%EXPORT Create an Export Object.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/12/14 15:20:28 $

error(nargchk(1,1,nargin,'struct'));

hXP = sigio.export;

hXP.Data = data;

set(hXP, 'Version', 1.0);

settag(hXP);

% [EOF]
