function filters = setfilters(this, filters)
%SETFILTERS   PreSet function for the filters.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2006/06/27 23:40:36 $

old_n_filters   = length(this.Filters);
old_isquantized = lclisquantized(this.Filters);

set(this, 'privFilters', filters);
resetfiltercache(this);

ca = get(this, 'CurrentAnalysis');
if ~isempty(ca), set(ca, 'Filters', this.Filters); end

% If we are going from 1 filter to multiple filters or if we are going from
% an unquantized filter to a quantized filter, turn on the legend.
if old_n_filters == 1 && length(filters) > 1 || ...
    ~old_isquantized && lclisquantized(filters)
    set(this, 'Legend', 'On');
end

sendfiltrespwarnings(this);

% -------------------------------------------------------------------------
function b = lclisquantized(filters)

% Return true if any of the filters are quantized.
b = false;
if isempty(filters), return; end
for indx = 1:length(filters)
    b = isquantized(filters(indx).Filter) || b;
end

% [EOF]
