function [m, f] = getmarker(this, lndx)
%GETMARKER   Return the marker to use for the given line index.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.2.4.5 $  $Date: 2005/12/22 19:03:59 $

m = {};
f = {};

for indx = 1:length(this.Filters)
    cFilt = this.Filters(indx).Filter;
    if showpoly(this.FilterUtils),
        npoly = npolyphase(cFilt);
    else
        npoly = 1;
    end
    if isquantized(cFilt) && showref(this.FilterUtils),
        m = [m repmat({{'s', 'x'}}, 1, npoly)       repmat({{'o', '*'}}, 1, npoly)];
        f = [f repmat({{'none', 'auto'}}, 1, npoly) repmat({{'auto', 'auto'}}, 1, npoly)];
    else
        m = [m repmat({{'o', '*'}}, 1, npoly)];
        f = [f repmat({{'auto', 'auto'}}, 1, npoly)];
    end
end

if ~isempty(this.SOSViewOpts) && length(this.Filters) == 1
    if isa(this.Filters(1).Filter, 'dfilt.abstractsos')
        nresps = getnresps(this.SOSViewOpts, this.Filters(1).Filter);
        m = repmat(m, 1, nresps);
        f = repmat(f, 1, nresps);
    end
end

if nargin > 1,
    m = m{lndx};
    f = f{lndx};
end

% [EOF]
