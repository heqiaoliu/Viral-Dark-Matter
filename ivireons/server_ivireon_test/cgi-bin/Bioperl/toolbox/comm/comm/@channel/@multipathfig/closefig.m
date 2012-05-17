function closefig(h);
%CLOSEFIG  Close figure window for multipath figure object.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/27 22:16:25 $

h.FigureHandle = [];

% Check to see whether associated with Simulink block.
chan = h.CurrentChannel;
blk = chan.SimulinkBlock;
if ~isempty(blk)
    % Make sure enableProbe menu setting is 0.
    set_param(blk, 'enableProbe', '0');
    chan.PrivateData.EnableProbe = false;
    % Set figure closed flag for Simulink.  This is important to avoid the
    % figure opening again during a call to updatestates.
    h.SimulinkBlkFigClosedFlag = true;
end
