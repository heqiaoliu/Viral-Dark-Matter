function h2 = filtgaussian_copy(h)
%COPY  Make a copy of a filtgaussian object.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/10/16 04:46:48 $

% Copy filtgaussian object.
h2 = copy(h);

h2.DopplerSpectrum = copy(h.DopplerSpectrum);

% Copy sigstatistics object.
for i = 1:length(h.Statistics)
    h2.Statistics(i) = sigstatistics_copy(h.Statistics(i));
end

% Copy buffer objects.
h2.Autocorrelation = copy(h.Autocorrelation);
h2.PowerSpectrum = copy(h.PowerSpectrum);

% Make sure that the numeric values in the PrivateData structure are copied to a
% new memory location. This can be done by adding a zero to the field values. We
% need to do this since the structure will be passed to a C-MEX function that
% will write in place to the memory locations of the structure fields. If the
% copied structure fields are not moved to a different memory location, the
% original and copied structures will change simultaneously in the C-MEX file. 
h2.PrivateData = struct;
fn = fieldnames(h.PrivateData);
for idx = 1:length(fn)
    if isnumeric(h.PrivateData.(fn{idx}))
        h2.PrivateData.(fn{idx}) = h.PrivateData.(fn{idx}) + 0;
    else
        h2.PrivateData.(fn{idx}) = h.PrivateData.(fn{idx});
    end
end

