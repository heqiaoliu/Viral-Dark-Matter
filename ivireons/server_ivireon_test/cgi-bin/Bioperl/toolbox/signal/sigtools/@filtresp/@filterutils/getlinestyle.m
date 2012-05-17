function s = getlinestyle(this, indx)
%GETLINESTYLE   Returns the line style to use for Frequency plots.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2005/12/22 19:03:50 $

s = {};
for idx = 1:length(this.Filters)
    cFilt = this.Filters(idx).Filter;
    cs = {'-'};
    if ispolyphase(cFilt) && showpoly(this),
        cs = repmat(cs, 1, npolyphase(cFilt));
    end
    if isquantized(this.Filters(idx).Filter) && showref(this),
        cs = [cs repmat({'-.'}, 1, length(cs))];
    end
    s = [s cs];
end

if length(this.Filters) == 1 && ...
        ~isempty(this.SOSViewOpts)
    if isa(this.Filters(1).Filter, 'dfilt.abstractsos')
        s = repmat(s, getnresps(this.SOSViewOpts, this.Filters(1).Filter), 1);
        s = s(:)';
    end
end

if isempty(s)
    s = {'-'};
else
    s = s{indx};
end

% [EOF]
