function label = plotcmd2label(plotcmd)
% PLOTCMD2LABEL Given a plot command compute a GUI label.
%
 
% Author(s): John W. Glass 19-Mar-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/04/21 04:49:01 $

switch plotcmd
    case 'none'
        key = 'NoneLabel';
    case 'step'
        key = 'StepPlotLabel';
    case 'bode'
        key = 'BodePlotLabel';
    case 'bodemag'
        key = 'BodeMagPlotLabel';
    case 'nichols'
        key = 'NicholsPlotLabel';
    case 'nyquist'
        key = 'NyquistPlotLabel';
    case 'sigma'
        key = 'SigmaPlotLabel';
    case 'pzmap'
        key = 'PZMapLabel';
    case 'iopzmap'
        key = 'IOPZMapLabel';
    case 'lsim'
        key = 'LSIMLabel';
    case 'initial'
        key = 'InitialLabel';
    case 'impulse'
        key = 'ImpulseLabel';
end

label = ctrlMsgUtils.message(sprintf('Slcontrol:linearizationtask:%s',key));
