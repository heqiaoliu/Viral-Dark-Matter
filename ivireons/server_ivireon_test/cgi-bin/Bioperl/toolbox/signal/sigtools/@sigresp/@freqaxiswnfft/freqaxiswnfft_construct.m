function allPrm = freqaxiswnfft_construct(this, varargin)
%FREQAXISWNFFT_CONSTRUCT

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/10/18 03:29:02 $

allPrm = this.freqaxiswfreqrange_construct(varargin{:});

createnfftprm(this, allPrm);

hPrm = getparameter(this, getnffttag(this));
l = [ ...
        handle.listener(hPrm, 'NewValue', @lclnfft_listener); ...
        handle.listener(hPrm, 'UserModified', @lclnfft_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'Listeners', union(l, this.Listeners));

% -------------------------------------------------------------------------
function lclnfft_listener(this, eventData)

hPrm = getparameter(this, getnffttag(this));

opts.nfft = getsettings(hPrm, eventData);

% Ignore the inf/nan case.  We'll handle ti later.
if opts.nfft == inf || isnan(opts.nfft)
    return;
end

setvalidvalues(getparameter(this, getfreqrangetag(this)), ...
    getfreqrangeopts(this, opts));
    
% [EOF]
