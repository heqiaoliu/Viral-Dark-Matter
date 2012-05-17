function pausebutton(h, pbObj);
%PAUSEBUTTON  Pause button callback for multipath figure object.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/04/13 05:33:22 $

fig = h.FigureHandle;
if get(pbObj, 'Value')==1
    set(pbObj, 'String', 'Resume');
else
    blk = h.CurrentChannel.SimulinkBlock;
    if isempty(blk)
        % MATLAB mode
        uiresume(fig);
    else
        % Simulink mode
        set_param(bdroot(blk), 'simulationcommand', 'continue');
    end
    set(pbObj, 'String', 'Pause');
end

h.refreshsnapshot;
