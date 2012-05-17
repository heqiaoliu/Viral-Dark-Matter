function dopts = designoptions(this, method)
%DESIGNOPTIONS   Return the design options.

%   Author(s): J. Schickler
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/10/18 03:25:57 $

hd = feval(getdesignobj(this, method));

dopts = designopts(this, method);

if isempty(fieldnames(dopts))
    return;
end

fn = setdiff(fieldnames(dopts), 'FilterStructure');

% The 'FilterStructure' property is not an enumerated value, so we need to
% get the options from the GETVALIDSTRUCTS method.
dopts.DefaultFilterStructure = dopts.FilterStructure;
dopts.FilterStructure        = getvalidstructs(hd);

% Loop over each of the fields to fix any problems.
for indx = 1:length(fn)
    
    dopts.(sprintf('Default%s', fn{indx})) = dopts.(fn{indx});
    dopts.(fn{indx}) = set(hd, fn{indx});
    
    if isempty(dopts.(fn{indx}))
        
        % If the field is empty we do not have an enumerated type, so we
        % need to get the valid values from the DataType of the property.
        p = findprop(hd, fn{indx});
        dopts.(fn{indx}) = get(p, 'DataType');
    elseif size(dopts.(fn{indx}), 2) == 1
        
        % Make sure that the strings show up by making the cell array a row.
        dopts.(fn{indx}) = transpose(dopts.(fn{indx}));
    end
end

% [EOF]
