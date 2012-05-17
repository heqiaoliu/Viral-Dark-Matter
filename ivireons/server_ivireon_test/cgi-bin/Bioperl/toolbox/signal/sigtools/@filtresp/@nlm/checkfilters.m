function [indices, msg] = checkfilters(this)
%CHECKFILTERS   Returns the valid filter indices.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2007/05/23 19:14:26 $

Hd = get(this, 'Filters');

indices = [];

% If we find 1 dfilt or 1 qfilt, then the analysis can work
for indx = 1:length(Hd)
    if isa(Hd(indx).Filter, 'dfilt.singleton') ...
            || (isa(Hd(indx).Filter, 'dfilt.multistage') && ~isa(Hd(indx).Filter, 'mfilt.multistage'))...
            || isa(Hd(indx).Filter, 'qfilt') ...
            || isa(Hd(indx).Filter, 'dfilt.abstractfarrowfd')
        indices = [indices indx];
    end
end

msg = sprintf('%s can only operate on single-rate filters.', this.Name);

% [EOF]
