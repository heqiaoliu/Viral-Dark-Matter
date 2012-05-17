function initialize(this,hBlk) 
 
% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:27 $

% INITIALIZE set dialog properties based on block properties
%  

%Call parent class initialization methods
this.initializeAssertionProps(hBlk)
this.initializeVisualizationProps(hBlk)
this.initializeLinearizationProps(hBlk)
this.initializeLoggingProps(hBlk)

%Initialize class properties
this.EnableUpperBound      = strcmp(hBlk.EnableUpperBound,'on');
this.UpperBoundFrequencies = hBlk.UpperBoundFrequencies;
this.UpperBoundMagnitudes  = hBlk.UpperBoundMagnitudes;
this.EnableLowerBound      = strcmp(hBlk.EnableLowerBound,'on');
this.LowerBoundFrequencies = hBlk.LowerBoundFrequencies;
this.LowerBoundMagnitudes  = hBlk.LowerBoundMagnitudes;
this.FrequencyUnits        = hBlk.FrequencyUnits;
this.MagnitudeUnits        = hBlk.MagnitudeUnits;
this.PhaseUnits            = hBlk.PhaseUnits;
end

