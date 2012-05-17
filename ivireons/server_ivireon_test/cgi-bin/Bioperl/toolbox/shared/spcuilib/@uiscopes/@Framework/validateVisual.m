function validateVisual(this, hVisual)
%VALIDATEVISUAL Validate the visual

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:44:26 $

hSource = this.DataSource;

if ~isempty(hSource)
    if nargin < 2
        hVisual = this.Visual;
    end
    [visualSuccess, visualException] = validateVisual(hSource, hVisual);
    if visualSuccess
        
        % The visual has now been validated against the source and we know
        % that it can properly operate.  Turn off the screen message so
        % that we can now see the visual.
        screenMsg(this, false);
    else
        
        % Something is wrong with the visual.  Put up the message from the
        % exception to show to the user.  Possible issues:
        %
        % Video is being fed with a source that does not have 1 or 3
        % components, or the matrix is not either MxN or MxNx3
        %
        % Time Domain is in frame processing but it we do not have a
        % discrete sample time and it cannot draw with that information.
        screenMsg(this, visualException.message);
    end
end

% [EOF]
