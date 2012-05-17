function h = dspfwiz(filtobj)
%DSPFWIZ Construct a dspfwiz object

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:18:23 $

error(nargchk(1,1,nargin,'struct'))

h = siggui.dspfwiz;

h.Filter = filtobj;

% EOF
