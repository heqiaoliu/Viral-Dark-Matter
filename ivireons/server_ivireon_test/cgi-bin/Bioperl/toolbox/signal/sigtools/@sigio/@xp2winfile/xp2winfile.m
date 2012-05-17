function h = xp2coeffile(data)
%XP2TXTFILE Constructor for the export to window text-file class.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:20:34 $

error(nargchk(1,1,nargin,'struct'));

h = sigio.xp2winfile;

set(h,'Version',1.0,'Data',data);

settag(h);

% [EOF]
