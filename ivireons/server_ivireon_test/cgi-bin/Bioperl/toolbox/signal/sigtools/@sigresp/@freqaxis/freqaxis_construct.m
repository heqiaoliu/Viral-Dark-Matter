function allPrm = freqaxis_construct(this,varargin)
%FREQAXIS_CONSTRUCT Constructor for the freqaxis class.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:28:51 $

allPrm = this.super_construct(varargin{:});

% Create parameters for the frequency response object.
%createfreqrangeprm(this, allPrm)
createparameter(this, allPrm, 'Normalized Frequency', 'freqmode', 'on/off', 'on');
% createparameter(this, allPrm, 'Frequency Units', 'frequnits', @charcheck, 'Hz');
createparameter(this, allPrm, 'Frequency Scale', 'freqscale', {'Linear', 'Log'});

hPrm = getparameter(this, 'freqmode');
l = [ ...
        handle.listener(hPrm, 'NewValue', @freqmode_listener); ...
        handle.listener(hPrm, 'UserModified', @freqmode_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'Listeners', l);

freqmode_listener(this, []);

% -------------------------------------------------------------------------
function charcheck(input)

if ~ischar(input),
    error(generatemsgid('FreqUnitsNotChar'), 'The frequency units must be a string.');
end

% [EOF]
