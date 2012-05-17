function initialize(this,hBlk) 
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:30 $

% INITIALIZE set dialog properties based on block properties
%  

%Call parent class initialization methods
this.initializeAssertionProps(hBlk)
this.initializeVisualizationProps(hBlk)
this.initializeLinearizationProps(hBlk)
this.initializeLoggingProps(hBlk)

%Initialize class properties
this.EnableStepResponseBound = strcmp(hBlk.EnableStepResponseBound,'on');
this.FinalValue              = hBlk.FinalValue;
this.RiseTime                = hBlk.RiseTime;
this.PercentRise             = hBlk.PercentRise;
this.SettlingTime            = hBlk.SettlingTime;
this.PercentSettling         = hBlk.PercentSettling;
this.PercentOvershoot        = hBlk.PercentOvershoot;
this.PercentUndershoot       = hBlk.PercentUndershoot;
this.FrequencyUnits          = hBlk.FrequencyUnits;
this.MagnitudeUnits          = hBlk.MagnitudeUnits;
this.PhaseUnits              = hBlk.PhaseUnits;
end