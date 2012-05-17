function constraintsID = getConstraintsID(this, longConstraint) %#ok<INUSL>
%GETCONSTRAINTSID Get the IDs for frequency and magnitude constraints.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2009/04/21 04:21:01 $

switch lower(longConstraint)
    %Frequency Costraints
    case 'passband edge and stopband edge'
        constraintsID = 'FpFst';
        
    case 'stopband edge and passband edge'
        constraintsID = 'FstFp';
        
    case 'passband and stopband edges'
        constraintsID = 'Fst1Fp1Fp2Fst2';
        
    case 'passband edge'
        constraintsID = 'Fp';
        
    case 'passband edges'
        constraintsID = 'Fp1Fp2';
        
    case 'passband edge and 3db point'
        constraintsID = 'FpF3dB';
        
    case 'stopband edge and 3db point'
        constraintsID = 'FstF3dB';
        
    case 'stopband edge'
        constraintsID = 'Fst';
        
    case 'stopband edges'
        constraintsID = 'Fst1Fst2';
        
    case '6db point'
        constraintsID = 'Fc';
        
    case '6db points'
        constraintsID = 'Fc1Fc2';
        
    case '3db point'
        constraintsID = 'F3dB';
        
    case '3db points'
        constraintsID = 'F3dB1F3dB2';
        
    case '3db point and stopband edge'
        constraintsID = 'F3dBFst';
        
    case '3db points and stopband width'
        constraintsID = 'F3dB1F3dB2BWst';
        
    case '3db point and passband edge'
        constraintsID = 'F3dBFp';
        
    case '3db points and passband width'
        constraintsID = 'F3dB1F3dB2BWp';
        
    case 'transition width'
        constraintsID = 'TW';
        
    case 'center frequency and quality factor'
        constraintsID = 'F0andQ';
        
    case 'center frequency and bandwidth'
        constraintsID = 'F0andBW';
        
    case 'center frequency, bandwidth, passband width'
        constraintsID = 'F0BWBWpass';
        
    case 'center frequency, bandwidth, stopband width'
        constraintsID = 'F0BWBWstop';
        
    case 'center frequency, bandwidth'
        constraintsID =  'F0BW';
        
    case 'center frequency, quality factor'
        constraintsID =  'F0Qa';
        
    case 'shelf type, cutoff frequency, quality factor'
        constraintsID =  'ShelfFcQa';
        
    case 'shelf type, cutoff frequency, shelf slope parameter'
        constraintsID =  'ShelfFcS';
        
    case 'low frequency, high frequency'
        constraintsID =  'FlowFhigh';
        
    case 'quality factor'
        constraintsID =  'Q';
        
    case 'bandwidth'
        constraintsID =  'BW';
        
        % Magnitude Costraints
        
    case 'unconstrained'
        constraintsID = 'unconstrained';
        
    case 'passband ripple and stopband attenuation'
        constraintsID = 'ApAst';
        
    case 'passband ripple and stopband attenuations'
        constraintsID = 'ApAst1Ast2';
        
    case 'passband ripples and stopband attenuation'
        constraintsID = 'Ap1Ap2Ast';
        
    case 'stopband attenuation and passband ripple'
        constraintsID = 'AstAp';
        
    case 'passband ripple'
        constraintsID = 'Ap';
        
    case 'stopband attenuation'
        constraintsID = 'Ast';
        
    case 'reference, center frequency, bandwidth, passband'
        constraintsID = 'GrefG0GBWGp';
        
    case 'reference, center frequency, bandwidth, stopband'
        constraintsID = 'GrefG0GWGst';
        
    case 'reference, center frequency, bandwidth, passband, stopband'
        constraintsID = 'GrefG0GBWGpGst';
        
    case 'reference, center frequency, bandwidth'
        constraintsID = 'GrefG0GBW';
        
    case 'reference, center frequency'
        constraintsID = 'GrefG0';
        
    case 'boost/cut'
        constraintsID = 'Gbc';
        
        
    otherwise
        error(generatemsgid('InternalError'),'Unrecognized constraint');
end



% [EOF]
