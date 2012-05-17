function allPrm = timeresp_construct(this, varargin)
%TIMERESP_CONSTRUCT Check the inputs

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2004/12/26 22:19:01 $

this.FilterUtils = filtresp.filterutils(varargin{:});
findclass(findpackage('dspopts'), 'sosview'); % g 227896
addprops(this, this.FilterUtils);

allPrm = this.timeaxis_construct(varargin{:});

createparameter(this, allPrm, 'Specify Length', 'uselength', {'Default', 'Specified'});
createparameter(this, allPrm, 'Length', 'impzlength', [1 1 inf], 50);

hPrm    = getparameter(this, 'uselength');
l = [ this.Listeners;
        handle.listener(hPrm, 'NewValue', @uselength_listener); ...
        handle.listener(hPrm, 'UserModified', @uselength_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'Listeners', l);

uselength_listener(this, []);

% ----------------------------------------------------------
function uselength_listener(this, eventData)

usel = getsettings(getparameter(this, 'uselength'), eventData);

if strcmpi(usel, 'default'),
    disableparameter(this, 'impzlength');
else
    enableparameter(this, 'impzlength');
end


% [EOF]
