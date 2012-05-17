function this = xp2wksp(data)
%XP2WKSP Constructor for the export to workspace class.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:20:36 $

error(nargchk(1,1,nargin,'struct'));

this = sigio.xp2wksp;
set(this,'Version', 1.0,'Data',data);

abstractxpdestwvars_construct(this);

settag(this);

% [EOF]
