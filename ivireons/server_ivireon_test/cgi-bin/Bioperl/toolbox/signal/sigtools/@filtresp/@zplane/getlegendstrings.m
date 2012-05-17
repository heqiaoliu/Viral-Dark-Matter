function allstr = getlegendstrings(this)
%GETLEGENDSTRINGS

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2004/12/26 22:19:06 $

allstr = {};

Hd = get(this, 'Filters');

if length(Hd) == 0
    return;
elseif length(Hd) == 1 && ...
        ~isempty(this.SOSViewOpts) && ...
        isa(Hd(1).Filter, 'dfilt.abstractsos')
    
    name = get(Hd, 'Name');
    if isempty(name)
        name = 'Filter #1';
    end
        
    names = getnames(this.SOSViewOpts, Hd.Filter);
    for indx = 1:length(names)
        if isquantized(Hd.Filter) && showref(this.FilterUtils)
            allstr{end+1} = sprintf('%s: %s: Quantized Zero', name, names{indx});
            allstr{end+1} = sprintf('%s: %s: Reference Zero', name, names{indx});
            allstr{end+1} = sprintf('%s: %s: Quantized Pole', name, names{indx});
            allstr{end+1} = sprintf('%s: %s: Reference Pole', name, names{indx});
        else
            allstr{end+1} = sprintf('%s: %s: Zero', name, names{indx});
            allstr{end+1} = sprintf('%s: %s: Pole', name, names{indx});
        end
    end
    return;
end

str = usesaxes_getlegendstrings(this);
sndx = 0;

for indx = 1:length(Hd)
    cFilt = Hd(indx).Filter;
    if ispolyphase(cFilt) && showpoly(this.FilterUtils)
        
        sndx = sndx + 1;
        for jndx = 1:npolyphase(cFilt)
            allstr{end+1} = sprintf('%s Polyphase (%d) Zero', str{sndx}, jndx);
            allstr{end+1} = sprintf('%s Polyphase (%d) Pole', str{sndx}, jndx);
        end
    elseif isquantized(cFilt) && showref(this.FilterUtils),
        sndx = sndx + 2;
        allstr{end+1} = sprintf('%s Zero', str{sndx-1});
        allstr{end+1} = sprintf('%s Zero', str{sndx});
        allstr{end+1} = sprintf('%s Pole', str{sndx-1});
        allstr{end+1} = sprintf('%s Pole', str{sndx});
    else
        sndx = sndx + 1;
        allstr{end+1} = sprintf('%s: Zero', str{sndx});
        allstr{end+1} = sprintf('%s: Pole', str{sndx});
    end
end

% [EOF]
