function updateFrameData(this, doReadoutUpdate)
%UPDATEFRAMEDATA <short description>
%   OUT = UPDATEFRAMEDATA(ARGS) <long description>

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/05/20 03:08:21 $

try
    updateVisual(this);
    
    % Update frame counter
    if nargin<2 || doReadoutUpdate
        updateFrameReadout(this.Controls);
    end
catch e
    
    error(e.identifier, 'An error occurred while reading frame %d.\n%s',...
        this.Controls.CurrentFrame, uiservices.cleanErrorMessage(e));
end

% [EOF]
