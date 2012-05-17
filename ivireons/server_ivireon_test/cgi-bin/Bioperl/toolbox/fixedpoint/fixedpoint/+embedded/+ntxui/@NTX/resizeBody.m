function resizeBody(ntx)
% Resize histogram display region
% Invoked when hBodyPanel resizes

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:46 $

% The readout text sets the y-pos for many other display elements,
% whether the readout is visible or not.  We only need to adjust the
% readout ypos if a resize occurs.  Do this before ylimits
updateDTXTextYPos(ntx);
initHistDisplay(ntx);
resizeXRangeIndicators(ntx);
updateSignedTextYPos(ntx);
