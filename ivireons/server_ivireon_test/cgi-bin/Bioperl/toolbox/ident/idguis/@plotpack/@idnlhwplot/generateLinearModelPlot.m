function generateLinearModelPlot(this)
% Main linear plot manager that spwans the linear plot of chosen type for
% idnlhw models.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:51:03 $

plottypes = get(this.UIs.LinearPlotTypeCombo,'string');
thistype = lower(plottypes{this.Current.LinearPlotTypeComboValue});
this.createNewPlotPanel;

%linmodel = getLinearModel(h.Model);
%pan(this.Figure,'off'); %paning is off by default on linear plots

switch thistype
    case {'step','impulse'}
        this.generateTimeRespPlot(thistype);
    case 'bode'
        warning off MATLAB:Axes:NegativeDataInLogAxis
        this.generateBodePlot;
        warning on MATLAB:Axes:NegativeDataInLogAxis
    case 'pole-zero map'
        this.generatePZPlot;
    otherwise
        ctrlMsgUtils.error('Ident:idguis:idnlhwPlot1')
end
