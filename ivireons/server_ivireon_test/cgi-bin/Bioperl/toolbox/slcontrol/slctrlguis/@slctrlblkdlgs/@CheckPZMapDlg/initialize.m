function initialize(this,hBlk) 
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:43 $

% INITIALIZE set dialog properties based on block properties
%  

%Call parent class initialization methods
this.initializeAssertionProps(hBlk)
this.initializeVisualizationProps(hBlk)
this.initializeLinearizationProps(hBlk)
this.initializeLoggingProps(hBlk)

%Initialize class properties
this.EnableSettlingTime     = strcmp(hBlk.EnableSettlingTime,'on');
this.SettlingTime           = hBlk.SettlingTime;
this.EnablePercentOvershoot = strcmp(hBlk.EnablePercentOvershoot,'on');
this.PercentOvershoot       = hBlk.PercentOvershoot;
this.EnableDampingRatio     = strcmp(hBlk.EnableDampingRatio,'on');
this.DampingRatio           = hBlk.DampingRatio;
this.EnableNaturalFrequency = strcmp(hBlk.EnableNaturalFrequency,'on');
this.NaturalFrequency       = hBlk.NaturalFrequency;
this.NaturalFrequencyBound  = hBlk.NaturalFrequencyBound;
this.FrequencyUnits         = hBlk.FrequencyUnits;
this.MagnitudeUnits         = hBlk.MagnitudeUnits;
this.PhaseUnits             = hBlk.PhaseUnits;
end

