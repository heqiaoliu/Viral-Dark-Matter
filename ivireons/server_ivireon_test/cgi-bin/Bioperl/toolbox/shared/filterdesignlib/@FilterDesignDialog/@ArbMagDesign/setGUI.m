function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/20 03:03:11 $

b = true;

hfdesign = getfdesign(Hd);
if ~strncmp(get(hfdesign, 'Response'), 'Arbitrary Magnitude', 19)
    b = false;
    return;
end

switch lower(hfdesign.Specification)
    case 'n,f,a'
        
        set(this.Band1, ...
            'Frequencies', mat2str(hfdesign.Frequencies), ...
            'Amplitudes',  mat2str(hfdesign.Amplitudes));
    case {'n,b,f,a', 'nb,na,b,f,a'}
        
        set(this, 'NumberOfBands', hfdesign.NBands-1);
        
        for indx = 1:hfdesign.NBands
            set(this.(sprintf('Band%d', indx)), ...
                'Frequencies', mat2str(hfdesign.(sprintf('B%dFrequencies', indx))), ...
                'Amplitudes', mat2str(hfdesign.(sprintf('B%dAmplitudes', indx))));
        end

    case 'nb,na,f,a'
        
        set(this.Band1, ...
            'Frequencies', mat2str(hfdesign.Frequencies), ...
            'Amplitudes',  mat2str(hfdesign.Amplitudes));
        
    case 'n,f,h'
        set(this, 'ResponseType', 'Frequency Response');
        set(this.Band1, ...
            'Frequencies', num2str(hfdesign.Frequencies), ...
            'Amplitudes',  num2str(hfdesign.FreqResponse));
    case 'n,b,f,h'
        set(this, 'ResponseType', 'Frequency Response', ...
            'NumberOfBands', hfdesign.NBands-1);
        
        for indx = 1:hfdesign.NBands
            set(this.(sprintf('Band%d', indx)), ...
                'Frequencies', mat2str(hfdesign.(sprintf('B%dFrequencies', indx))), ...
                'Amplitudes', mat2str(hfdesign.(sprintf('B%dFreqResponse', indx))));
        end

    otherwise
        error(generatemsgid('IncompleteConstraints'), ...
            'Internal Error: ArbMag ''%s'' incomplete', hfdesign.Specification);
end

abstract_setGUI(this, Hd);

% [EOF]
