function denormalize(Hd)
%DENORMALIZE Undo normalization applied by NORMALIZE.
% 
%   See also: NORMALIZE

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:07:56 $

for k=1:length(Hd.Stage)
    denormalize(Hd.Stage(k));
end


% [EOF]
