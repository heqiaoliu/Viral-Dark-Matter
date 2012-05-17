function cleanup(this, hVisParent)
%CLEANUP  Cleanup the object when unrendered.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/02/18 02:24:52 $

cleanupAxes(this, hVisParent)
this.InfoText = [];

% [EOF]
