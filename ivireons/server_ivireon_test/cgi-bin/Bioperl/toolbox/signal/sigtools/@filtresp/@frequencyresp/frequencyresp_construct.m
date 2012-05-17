function allPrm = frequencyresp_construct(this, varargin)
%FREQUENCYRESP_CONSTRUCT Perform constructions tasks and return all found
%parameters
%
%  Search for parameters and setup the freqaxis super class properties
%  Create the FilterUtils object and pass it the input (to find the
%  filters).
%  Add a listener to the Filter to look for complex filters.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.5 $  $Date: 2004/12/26 22:18:46 $

allPrm = this.freqaxiswfreqvec_construct(varargin{:});

this.FilterUtils = filtresp.filterutils(varargin{:});
findclass(findpackage('dspopts'), 'sosview'); % g 227896
addprops(this, this.FilterUtils);

l = handle.listener(this.FilterUtils, this.FilterUtils.findprop('Filters'), ...
        'PropertyPostSet', @lclfilters_listener);
set(l, 'CallbackTarget', this);
set(this, 'FilterListener', l);

lclfilters_listener(this);

% ---------------------------------------------------------------------------
function lclfilters_listener(this, eventData)
%LCLFILTERS_LISTENER Looks for complex filters and updates the range.

% If any of the filters are not real, make the range -pi to pi.
if isreal(this),
    if get(this, 'hiddenImagCrumb'),
        opts = getfreqrangeopts(this);
        set(this, 'FrequencyRange', opts{1});
        set(this, 'hiddenImagCrumb', false);
    end
else
    opts = getfreqrangeopts(this);
    if any(strcmpi(this.FrequencyRange, opts{1})),
        set(this, 'hiddenImagCrumb', true);
        set(this, 'FrequencyRange', opts{3});
    end
end

% [EOF]
