function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/20 03:03:24 $

b = true;
hfdesign = getfdesign(Hd);
if ~strcmpi(get(hfdesign, 'Response'), 'lowpass')
    b = false;
    return;
end
switch hfdesign.Specification
    case 'Fp,Fst,Ap,Ast'
        set(this, ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Fstop', num2str(hfdesign.Fstop), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,F3dB'
        set(this, ...
            'privFrequencyConstraints', '3dB point', ...
            'privMagnitudeConstraints', 'unconstrained', ...
            'F3dB', num2str(hfdesign.F3db));
    case 'N,F3dB,Ap'
        set(this, ...
            'privFrequencyConstraints', '3dB point', ...
            'privMagnitudeConstraints', 'Passband ripple', ...
            'F3dB',  num2str(hfdesign.F3db), ...
            'Apass', num2str(hfdesign.Apass));
    case 'N,F3dB,Ap,Ast'
        set(this, ...
            'privFrequencyConstraints', '3dB point', ...
            'privMagnitudeConstraints', 'Passband ripple and stopband attenuation', ...
            'F3dB',  num2str(hfdesign.F3db), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,F3dB,Ast'
        set(this, ...
            'privFrequencyConstraints', '3dB point', ...
            'privMagnitudeConstraints', 'Stopband attenuation', ...
            'F3dB',  num2str(hfdesign.F3db), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,F3dB,Fst'
        set(this, ...
            'privFrequencyConstraints', '3dB point and stopband edge', ...
            'privMagnitudeConstraints', 'unconstrained', ...
            'F3dB',  num2str(hfdesign.F3db), ...
            'Fstop', num2str(hfdesign.Fstop));
    case 'N,Fc'
        set(this, ...
            'privFrequencyConstraints', '6dB point', ...
            'privMagnitudeConstraints', 'unconstrained', ...
            'F6dB',  num2str(hfdesign.Fcutoff));
    case 'N,Fc,Ap,Ast'
        set(this, ...
            'privFrequencyConstraints', '6dB point', ...
            'privMagnitudeConstraints', 'Passband ripple and stopband attenuation', ...
            'F6dB',  num2str(hfdesign.Fcutoff), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,Fp,Ap'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge', ...
            'privMagnitudeConstraints', 'Passband ripple', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Apass', num2str(hfdesign.Apass));
    case 'N,Fp,Ap,Ast'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge', ...
            'privMagnitudeConstraints', 'Passband ripple and stopband attenuation', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,Fp,F3dB'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge and 3dB point', ...
            'privMagnitudeConstraints', 'unconstrained', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'F3dB',  num2str(hfdesign.F3dB));
    case 'N,Fp,Fst'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge and stopband edge', ...
            'privMagnitudeConstraints', 'unconstrained', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Fstop', num2str(hfdesign.Fstop));
    case 'N,Fp,Fst,Ap'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge and stopband edge', ...
            'privMagnitudeConstraints', 'Passband ripple', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Fstop', num2str(hfdesign.Fstop), ...
            'Apass', num2str(hfdesign.Apass));
    case 'N,Fp,Fst,Ast'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge and stopband edge', ...
            'privMagnitudeConstraints', 'Stopband attenuation', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Fstop', num2str(hfdesign.Fstop), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,Fst,Ap,Ast'
        set(this, ...
            'privFrequencyConstraints', 'Stopband edge', ...
            'privMagnitudeConstraints', 'Passband ripple and stopband attenuation', ...
            'Fstop', num2str(hfdesign.Fstop), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,Fst,Ast'
        set(this, ...
            'privFrequencyConstraints', 'Stopband edge', ...
            'privMagnitudeConstraints', 'Stopband attenuation', ...
            'Fstop', num2str(hfdesign.Fstop), ...
            'Astop', num2str(hfdesign.Astop));
    case 'Nb,Na,Fp,Fst'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge and stopband edge', ...
            'privMagnitudeConstraints', 'unconstrained', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Fstop', num2str(hfdesign.Fstop));
    otherwise
        error(generatemsgid('IncompleteConstraints'), ...
            'Internal Error: Lowpass ''%s'' incomplete', hfdesign.Specification);
end

abstract_setGUI(this, Hd);

% [EOF]