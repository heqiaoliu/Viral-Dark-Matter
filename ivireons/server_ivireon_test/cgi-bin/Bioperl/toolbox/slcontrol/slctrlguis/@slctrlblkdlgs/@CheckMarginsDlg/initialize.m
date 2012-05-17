function initialize(this,hBlk) 
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/30 00:44:05 $

% INITIALIZE set dialog properties based on block properties
%  

%Call parent class initialization methods
this.initializeAssertionProps(hBlk)
this.initializeVisualizationProps(hBlk)
this.initializeLinearizationProps(hBlk)
this.initializeLoggingProps(hBlk)

%Initialize class properties
this.EnableMargins  = strcmp(hBlk.EnableMargins,'on');
this.GainMargin     = hBlk.GainMargin;
this.PhaseMargin    = hBlk.PhaseMargin;
this.PlotType       = hBlk.PlotType;
this.FrequencyUnits = hBlk.FrequencyUnits;
this.MagnitudeUnits = hBlk.MagnitudeUnits;
this.PhaseUnits     = hBlk.PhaseUnits;
this.FeedbackSign   = hBlk.FeedbackSign;
end

