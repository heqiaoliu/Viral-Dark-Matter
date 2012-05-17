function out = shouldShowControls(this, controlType)
%SHOULDSHOWCONTROLS For source specific control visibility
% Returns true if the controls should be visible on the scope.  

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/07 14:24:04 $

%shouldShowControls Returns true if the playback toolbar should be
%visible on the scope. If the ShowSnapShotButton property is
%false, then don't show the playback controls toolbar since it's
%the only widget on the toolbar.

out = true;
if ~this.getPropValue('ShowSnapShotButton')
    out = false;
end
% [EOF]
