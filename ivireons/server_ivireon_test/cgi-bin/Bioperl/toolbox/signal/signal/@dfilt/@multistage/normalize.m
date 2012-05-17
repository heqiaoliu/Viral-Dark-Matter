function varargout = normalize(Hd)
%NORMALIZE Normalize coefficients of each section between -1 and 1.
%   G = NORMALIZE(Hd) returns the gains due to normalization.

%   See also: DENORMALIZE

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:29 $

for k=1:length(Hd.Stage)
    sv{k} = normalize(Hd.Stage(k));
end

if nargout==1,
    varargout = {sv};
end



% [EOF]
