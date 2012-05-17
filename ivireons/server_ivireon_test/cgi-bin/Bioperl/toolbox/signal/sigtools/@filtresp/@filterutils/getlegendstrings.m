function strs = getlegendstrings(this, str)
%GETLEGENDSTRINGS   Get the strings for the legend.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/08/01 12:25:41 $

if nargin > 1
    extra = [' ' xlate(str)];
else
    extra = '';
end

if isempty(extra)
    extrad = extra;
else
    extrad = [':' extra];
end

strs = {};

Hd = get(this, 'Filters');

if isempty(Hd)
    return;
elseif length(Hd) == 1 && ...
        isa(Hd.Filter, 'dfilt.abstractsos') && ...
        ~isempty(this.SOSViewOpts)
    if ~strcmpi(this.SOSViewOpts.View, 'complete')

        name = get(Hd, 'Name');
        if isempty(name)
            name = 'Filter #1';
        end

        names = getnames(this.SOSViewOpts, Hd.Filter);
        qstrs = {};
        rstrs = {};

        for indx = 1:length(names)
            if isquantized(Hd.Filter) && showref(this)
                qstrs{indx} = sprintf('%s: %s: Quantized%s', name, names{indx}, extra);
                rstrs{indx} = sprintf('%s: %s: Reference%s', name, names{indx}, extra);
            else
                rstrs{indx} = sprintf('%s: %s%s', name, names{indx}, extra);
            end
        end

        strs = {qstrs{:} rstrs{:}};
        return;
    end
end

for indx = 1:length(Hd),
    name = get(Hd(indx), 'Name');
    if isempty(name),
        name = sprintf('Filter #%d', indx);
    end

    cFilt = Hd(indx).Filter;

    if isquantized(cFilt) && showref(this) && ispolyphase(cFilt) && showpoly(this)

        for jndx = 1:npolyphase(cFilt)
            strs = {strs{:}, sprintf('%s: Quantized Polyphase(%d)%s', name, jndx, extra)};
        end
        for jndx = 1:npolyphase(cFilt)
            strs = {strs{:}, sprintf('%s: Reference Polyphase(%d)%s', name, jndx, extra)};
        end
    elseif isquantized(cFilt) && showref(this)

        strs = {strs{:}, sprintf('%s: Quantized%s', name, extra)};
        strs = {strs{:}, sprintf('%s: Reference%s', name, extra)};
    elseif ispolyphase(cFilt) && showpoly(this)

        for jndx = 1:npolyphase(cFilt)
            strs = {strs{:}, sprintf('%s: Polyphase(%d)%s', name, jndx, extra)};
        end
    else

        strs = {strs{:}, sprintf('%s%s', name, extrad)};
    end
end

% [EOF]
