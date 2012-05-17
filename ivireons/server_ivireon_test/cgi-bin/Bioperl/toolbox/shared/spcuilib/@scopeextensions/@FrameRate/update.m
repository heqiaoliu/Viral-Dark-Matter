function update(this, newFPS)
%UPDATE Update FrameRate object to react to a new movie (source data object)

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/03/31 18:41:19 $

% If new FPS already set in theFrameRate object,
% there will be no 2nd arg passed in - just use
% current .desired_fps value
if nargin < 2
    % Input was derived from DataAbstract - must be a movie source object
    %
    % Resetting from new movie
    % Need to reset these properties in response to a new data source:
    %
    this.SourceFPS    = 1/getSampleTimes(this.hAppInst.DataSource, 1);
    this.DesiredFPS   = this.SourceFPS;
    this.SpeedPreset  = 1;  % 1.0x playback
else
    % Resetting from a scalar value
    this.SourceFPS   = newFPS;
    this.DesiredFPS  = this.SourceFPS;
    this.SpeedPreset = 0;  % signifies change required,
    % since fps is an unknown value
end

% [EOF]
