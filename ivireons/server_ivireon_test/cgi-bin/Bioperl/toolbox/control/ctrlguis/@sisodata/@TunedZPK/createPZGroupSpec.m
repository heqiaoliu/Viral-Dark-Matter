function PZGroupSpec = createPZGroupSpec(this)
% Create Model API Parameter Spec for PZGroups

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:47:16 $
  
PZGroup = this.PZGroup;

if length(PZGroup) == 0
    PZGroupSpec = [];
else

    for ct = length(PZGroup):-1:1
        PZGroupSpec(ct,1) = PZGroup(ct).getParameterSpec;
    end

end

