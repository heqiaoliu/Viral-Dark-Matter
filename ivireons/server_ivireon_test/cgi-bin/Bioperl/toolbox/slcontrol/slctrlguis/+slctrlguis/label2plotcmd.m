function plotcmd = label2plotcmd(label)
% LABEL2PLOTCMD  Find the plot command given a GUI label
%
 
% Author(s): John W. Glass 19-Mar-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/04/21 04:49:00 $

switch label
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:NoneLabel')
        plotcmd = 'none';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:StepPlotLabel')
        plotcmd = 'step';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:BodePlotLabel')
        plotcmd = 'bode';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:BodeMagPlotLabel')
        plotcmd = 'bodemag';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:NicholsPlotLabel')
        plotcmd = 'nichols';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:NyquistPlotLabel')
        plotcmd = 'nyquist';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:SigmaPlotLabel')
        plotcmd = 'sigma';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:PZMapLabel')
        plotcmd = 'pzmap';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:IOPZMapLabel')
        plotcmd = 'iopzmap';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:LSIMLabel')
        plotcmd = 'lsim';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:InitialLabel')
        plotcmd = 'initial';
    case ctrlMsgUtils.message('Slcontrol:linearizationtask:ImpulseLabel')
        plotcmd = 'impulse';
end