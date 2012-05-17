function varargout = formatnames(this, labels, names)
%FORMATNAMES   Format the names using the database.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/06/06 17:06:11 $

if nargin < 2,
    labels = this.VariableLabels;
end
if nargin < 3,
    names  = this.VariableNames;
end

if isempty(labels), labels = ''; end

oldlbls = get(this, 'PreviousLabelsAndNames');

% Replace spaces with _ and remove non "word" characters.
labels = strrep(labels, ' ', '_');
for indx = 1:length(labels)
    jndx = regexp(labels{indx}, '\w');
    labels{indx} = labels{indx}(jndx);
    if isprop(this, 'ExportAs') & isdynpropenab(this, 'ExportAs')
        labels{indx} = [strrep(this.ExportAs, ' ', '') labels{indx}];
    end
end

if isempty(oldlbls),
    oldlbls = cell2struct(names(:)', labels(:)', 2);
else
    for indx = 1:length(labels),
        if isfield(oldlbls, labels{indx}),
            names{indx} = oldlbls.(labels{indx});
        else
            oldlbls.(labels{indx}) = names{indx};
        end
    end
end

set(this, 'PreviousLabelsAndNames', oldlbls);

if nargout,
    varargout = {names};
else,
    set(this, 'VariableNames', names);
end

% [EOF]
