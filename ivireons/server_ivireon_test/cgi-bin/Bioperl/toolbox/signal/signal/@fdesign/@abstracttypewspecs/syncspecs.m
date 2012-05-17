function syncspecs(this, newspecs)
%SYNCSPECS   Sync specs from the current specs to a new specs object.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:23 $

% Grab the old Fs information.
if ~isempty(this.CurrentSpecs),

    syncfs(this, newspecs);
    syncotherprops(this, newspecs);
end

% -------------------------------------------------------------------------
function syncfs(this, newspecs);

oldspecs = get(this, 'CurrentSpecs');
normalized = oldspecs.NormalizedFrequency;
if oldspecs.NormalizedFrequency,
    
    % If we are coming from a normalized setting, unnormalize, grab the fs
    % and renormalize.
    normalizefreq(oldspecs,false);
    fs = get(oldspecs, 'Fs');
    normalizefreq(oldspecs,true);
else
    fs = get(oldspecs, 'Fs');
end

% Use the fs from the oldspecs so that if the user unnormalizes they will
% get what they had set in Fs in the old specs.
normalizefreq(newspecs,false,fs);
normalizefreq(newspecs,normalized);

% -------------------------------------------------------------------------
function syncotherprops(this, newspecs)

oldspecs = get(this, 'CurrentSpecs');

% Sync all other props.
p = propstosync(newspecs);
prop_modified = false(length(p), 1);
for indx = 1:length(p),
    if isprop(oldspecs, p{indx}),
        set(newspecs, p{indx}, get(oldspecs, p{indx}));
        prop_modified(indx) = true;
    end
end

p(prop_modified) = [];
allspecs         = get(this, 'AllSpecs');

for indx = 1:length(p)
    for jndx = 1:length(allspecs)
        if isprop(allspecs(jndx), p{indx})
            set(newspecs, p{indx}, get(allspecs(jndx), p{indx}));
            break
        end
    end
end

% [EOF]
