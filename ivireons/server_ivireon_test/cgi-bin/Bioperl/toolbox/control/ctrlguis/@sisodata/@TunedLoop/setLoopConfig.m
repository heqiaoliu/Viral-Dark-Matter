function setLoopConfig(this,LoopData,LoopConfig)
% SETLOOPCONFIG
%
 
% Author(s): John W. Glass 03-Oct-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/05/23 07:52:57 $

try
    computeTunedLoop(this,LoopData,LoopConfig)
catch Ex
    if strcmp(Ex.identifier,'Slcontrol:controldesign:SignalNotInFeedbackLoop')
        errstr = sprintf(['The signal at the outport of the block %s, port %d is ',...
            'not in a feedback loop when using the selected Open-Loop configuration.  ',...
            'Returning to the previous configuration.'],LoopConfig.OpenLoop.BlockName,...
                                                        LoopConfig.OpenLoop.PortNumber);
    else
        msg = ltipack.utStripErrorHeader(Ex.message);
        errstr = sprintf(['The open loop %s could not be analyzed due ',...
            'to the following error: \n\n %s'],this.Name,msg);
    end
    javaMethodEDT('showMessageDialog','com.mathworks.mwswing.MJOptionPane', ...
        slctrlexplorer, errstr, xlate('SISO Design Task'), com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
    return
end

% If successful write the loop configuration data
this.LoopConfig.OpenLoop = LoopConfig.OpenLoop;
this.LoopConfig.LoopOpenings = LoopConfig.LoopOpenings;
