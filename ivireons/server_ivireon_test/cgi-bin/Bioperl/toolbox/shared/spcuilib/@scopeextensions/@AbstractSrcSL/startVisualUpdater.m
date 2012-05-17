function startVisualUpdater(this)
%STARTVISUALUPDATER 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:07:46 $

% If we are not in snapshot mode attach the source to the updater.
if ~this.SnapshotMode
    hUpdater = uiscopes.VisualUpdater.Instance;
    attach(hUpdater, this);
end

% [EOF]
