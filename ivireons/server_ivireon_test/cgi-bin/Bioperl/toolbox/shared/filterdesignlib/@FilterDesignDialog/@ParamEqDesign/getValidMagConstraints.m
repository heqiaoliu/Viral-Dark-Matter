function validMagConstraints = getValidMagConstraints(this)
%GETVALIDMAGCONSTRAINTS Get the validMagConstraints.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:13:26 $

validMagConstraints = set(this, 'MagnitudeConstraints')';

switch lower(this.FrequencyConstraints)
    case 'center frequency, bandwidth, passband width'
        validMagConstraints = validMagConstraints([1 3]);
    case 'center frequency, bandwidth, stopband width'
        validMagConstraints = validMagConstraints(2);
    case 'center frequency, bandwidth'
        validMagConstraints = validMagConstraints([1 2 3 4]);       
    case 'low frequency, high frequency'
        validMagConstraints = validMagConstraints([1 2 3 4]);                
    case 'center frequency, quality factor'
        validMagConstraints = validMagConstraints(5);  
    case 'shelf type, cutoff frequency, quality factor'
        validMagConstraints = validMagConstraints(6);                
    case 'shelf type, cutoff frequency, shelf slope parameter'
        validMagConstraints = validMagConstraints(6);                        
end

% [EOF]
