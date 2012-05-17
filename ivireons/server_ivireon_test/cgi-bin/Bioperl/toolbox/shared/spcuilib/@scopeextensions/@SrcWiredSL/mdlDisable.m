function mdlDisable(this, hRTBlock)
%MDLDISABLE Respond to mdlDisable events.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:34 $

% Get the latest data to the visual.
updateVisual(this);
updateTimeStatus(this);

% Insert a gap of nans.
insertGapInDataBuffer(this, hRTBlock.CurrentTime);

% Make sure that we cannot get new data (the nans) to display until we
% enable again and get a real mdlUpdate.
this.NewData = false;

% [EOF]
