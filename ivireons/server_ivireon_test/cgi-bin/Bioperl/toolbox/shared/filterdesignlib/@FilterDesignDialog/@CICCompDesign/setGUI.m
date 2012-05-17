function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:03:14 $

b = true;
hfdesign = getfdesign(Hd);
if ~strcmpi(get(hfdesign, 'Response'), 'cic compensator')
    b = false;
    return;
end

set(this, ...
    'NumberOfSections',  num2str(hfdesign.NumberOfSections), ...
    'DifferentialDelay', num2str(hfdesign.DifferentialDelay));

switch hfdesign.Specification
    case 'Fp,Fst,Ap,Ast'
        set(this, ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Fstop', num2str(hfdesign.Fstop), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,Fc,Ap,Ast'
        set(this, ...
            'privFrequencyConstraints', '6dB point', ...
            'privMagnitudeConstraints', 'Passband ripple and stopband attenuation', ...
            'F6dB', num2str(hfdesign.Fcutoff), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,Fp,Ap,Ast'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge', ...
            'privMagnitudeConstraints', 'Passband ripple and stopband attenuation', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,Fst,Ap,Ast'
        set(this, ...
            'privFrequencyConstraints', 'Stopband edge', ...
            'privMagnitudeConstraints', 'Passband ripple and stopband attenuation', ...
            'Fstop', num2str(hfdesign.Fstop), ...
            'Apass', num2str(hfdesign.Apass), ...
            'Astop', num2str(hfdesign.Astop));
    case 'N,Fp,Fst'
        set(this, ...
            'privFrequencyConstraints', 'Passband edge and stopband edge', ...
            'privMagnitudeConstraints', 'Unconstrained', ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Fstop', num2str(hfdesign.Fstop));
    otherwise
        error(generatemsgid('IncompleteConstraints'), ...
            'Internal Error: CICComp ''%s'' incomplete', hfdesign.Specification);
end

abstract_setGUI(this, Hd);

% [EOF]