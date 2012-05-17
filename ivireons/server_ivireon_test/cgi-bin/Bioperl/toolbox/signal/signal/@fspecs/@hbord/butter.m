function Hd = butter(this, varargin)
%BUTTER   Butterworth digital filter design.

%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:48:38 $

Hd = design(this, 'butter', varargin{:});
h = getfmethod(Hd);

if ishp(this),
    if isa(Hd,'mfilt.abstractmultirate'),
        error(generatemsgid('InvalidStructure'), ...
            'Multirate highpass halfband IIR filters are not supported.');
    end
    Hd = iirlp2hp(Hd,.5,.5);
    % Reset the contained FMETHOD.
    Hd.setfmethod(h);
end
