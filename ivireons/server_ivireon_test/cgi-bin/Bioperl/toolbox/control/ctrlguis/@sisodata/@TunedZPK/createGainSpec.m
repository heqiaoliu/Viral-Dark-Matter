function GainSpec = createGainSpec(this)
% Create Model API Parameter Spec for the Gain


%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2007/05/18 04:59:20 $
  
PID = modelpack.STParameterID(...
    'Gain', ...
    [1,1], ...
    this.Identifier, ...
    'double', ...
    {''});
GainSpec = modelpack.STParameterSpec(PID,{'Formatted', 'Invariant'});
    
GainSpec.Maximum = inf;
GainSpec.Minimum = -inf;
GainSpec.InitialValue = this.getFormattedGain;
GainSpec.Known = true;
GainSpec.TypicalValue = this.getFormattedGain;
    
    
    
    
    