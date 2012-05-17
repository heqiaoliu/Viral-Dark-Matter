function stopVisualUpdater(this)
%STOPVISUALUPDATER 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:11 $

hUpdater = uiscopes.VisualUpdater.Instance;
detach(hUpdater, this);

% [EOF]
