function mdlTerminate(this, block)
%MDLTERMINATE Called at model termination (stop).

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/05/20 03:07:56 $

if nargin > 1
    this.RunTimeBlock = block;
end

% Cache the final raw data.
this.RawDataCache = getRawData(this);

% Stop the visual for this scope from being updated.
stopVisualUpdater(this);

% Turn off the snapshot mode at stop.
setSnapShotMode(this, 'off');

% [EOF]
