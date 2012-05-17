function SavedData = saveconstr(Plot)
%SAVECONSTR  Saves design constraint.

%   Author(s): A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:29:34 $

Constraints = Plot.findconstr;
nc = length(Constraints);
SavedData = struct('Type',cell(nc,1),'Data',[]);

for ct=1:nc,
    SavedData(ct).Type = Constraints(ct).describe('identifier');
    SavedData(ct).Data = Constraints(ct).save;
end