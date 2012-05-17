function h2 = intfiltgaussian_copy(h)
%INTFILTGAUSSIAN_COPY  Copy properties from another object.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/16 04:46:49 $

% Copy intfiltgaussian object.
h2 = copy(h);

% Copy filtgaussian object.
h2.FiltGaussian = filtgaussian_copy(h.FiltGaussian);

% Copy interpfilter object. 
h2.InterpFilter = copy(h.InterpFilter);

% Make sure that the numeric values in the PrivateData structure are copied to a
% new memory location. This can be done by adding a zero to the field values. We
% need to do this since the structure will be passed to a C-MEX function that
% will write in place to the memory locations of the structure fields. If the
% copied structure fields are not moved to a different memory location, the
% original and copied structures will change simultaneously in the C-MEX file. 
h2.InterpFilter.PrivateData = struct;
fn = fieldnames(h.InterpFilter.PrivateData);
for idx = 1:length(fn)
    if isnumeric(h.InterpFilter.PrivateData.(fn{idx}))
        h2.InterpFilter.PrivateData.(fn{idx}) = ...
            h.InterpFilter.PrivateData.(fn{idx}) + 0;
    else
        h2.InterpFilter.PrivateData.(fn{idx}) = ...
            h.InterpFilter.PrivateData.(fn{idx});
    end        
end

