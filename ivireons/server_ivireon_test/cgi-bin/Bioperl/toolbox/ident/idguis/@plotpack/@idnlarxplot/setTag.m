function setTag(this,panel)
% set tag for the selected "Main" panel.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:02 $

tagstr = getTag(this); 
set(panel,'Tag',tagstr);
