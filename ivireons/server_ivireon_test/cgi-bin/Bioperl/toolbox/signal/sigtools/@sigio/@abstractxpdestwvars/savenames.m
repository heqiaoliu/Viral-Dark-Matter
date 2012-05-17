function savenames(this)
%SAVENAMES   Save the names in the database.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/10/18 21:10:46 $

labels = strrep(this.VariableLabels, ' ', '_');
for indx = 1:length(labels)
    jndx = regexp(labels{indx}, '\w');
    labels{indx} = labels{indx}(jndx);
    if isprop(this, 'ExportAs') & isdynpropenab(this, 'ExportAs')
        labels{indx} = [strrep(this.ExportAs, ' ', '') labels{indx}];
    end
end

names  = get(this, 'VariableNames');

oldlbls = get(this, 'PreviousLabelsAndNames');

for indx = 1:min(length(labels), length(names))
    oldlbls.(labels{indx}) = names{indx};
end

set(this, 'PreviousLabelsAndNames', oldlbls);

% [EOF]
