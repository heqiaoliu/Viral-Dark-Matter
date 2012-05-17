function filter_listener(h, eventData)
%FILTER_LISTENER Listener to the filter property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/06/17 12:54:40 $

names = getbackupnames(h);
sfs   = getbackupfs(h);

% Make sure that the old index does not exceed the number of new filters.
if length(names) < get(h, 'Index'),
    set(h, 'Index', length(names));
end

set(h, 'BackupNames', names);
set(h, 'BackupFs', sfs);

% We do not want cancel to undo these changes
resetoperations(h);

% -------------------------------------------------------------------
function names = getbackupnames(h)

filtobjs = get(h, 'Filters');
names    = get(filtobjs, 'Name');

if ~iscell(names), names = {names}; end

for indx = 1:length(names),
    if isempty(names{indx}),
        names{indx} = sprintf('Filter #%d', indx);
    end
end

% -------------------------------------------------------------------
function sfs   = getbackupfs(h)

filtobjs = get(h, 'Filters');
fs       = get(filtobjs, 'Fs'); if ~iscell(fs), fs = {fs}; end

for indx = 1:length(fs),
    if isempty(fs{indx}),
        sfs(indx).Value = 'Fs';
        sfs(indx).Units = 'Normalized';
    else
        [sfs(indx).Value sfs(indx).Units] = convert2engstrs(fs{indx});
        toosmall = {'a','f','p','\mu','m'};
        toolarge = {'T','P','E'};
        switch sfs(indx).Units,
        case toosmall
            v = str2num(sfs(indx).Value);
            v = convertfrequnits(v, sfs(indx).Units, 'm', toosmall)/1000;
            sfs(indx).Value = num2str(v);
            sfs(indx).Units = '';
        case toolarge,
            v = str2num(sfs(indx).Value);
            v = convertfrequnits(v, sfs(indx).Units, 'T', toolarge)*1000;
            sfs(indx).Value = num2str(v);
            sfs(indx).Units = 'G';
        end
        sfs(indx).Units = [sfs(indx).Units 'Hz'];
    end
end

% [EOF]
