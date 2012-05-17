function updateVisual(this)
%UPDATEVISUAL Update the visual only when there is new data.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:34 $

if this.NewData && ~isempty(this.Application.Visual) && this.IsSourceValid

    this.NewData         = false;
    this.UpdateRequested = false;
    update(this.Application.Visual);
    postUpdate(this.Application.Visual);
else
    
    % If there is no new data available to be displayed, flag the
    % source that a visual update was requested.
    this.UpdateRequested = true;
end

% [EOF]
