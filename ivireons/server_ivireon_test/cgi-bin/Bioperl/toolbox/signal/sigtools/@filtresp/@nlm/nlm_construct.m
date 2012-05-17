function nlm_construct(hObj, varargin)
%NLM_CONSTRUCT

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2008/05/31 23:27:47 $

allPrm = hObj.freqaxiswnfft_construct(varargin{:});
hObj.FilterUtils = filtresp.filterutils(varargin{:});
findclass(findpackage('dspopts'), 'sosview'); % g 227896
addprops(hObj, hObj.FilterUtils);

createparameter(hObj, allPrm, 'Number of Trials', 'montecarlo', [1 1 inf], 12);

% You cannot disable the nfft.  make sure the frequencyresp superclass
% did not do it.
d = get(hObj, 'DisabledParameters');
indx = strcmpi(d, 'nfft');
if ~isempty(indx),
    d(indx) = [];
    set(hObj, 'DisabledParameters', d);
end

% [EOF]
