function SavedData = saveconstr(Editor)
%SAVECONSTR  Saves design constraint.

%   Author(s): P. Gahinet
%   Revised: A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2005/12/22 17:43:04 $

Constraints = Editor.findconstr;
nc = length(Constraints);
SavedData = struct('Type',cell(nc,1),'Data',[]);

for ct=1:nc,
    SavedData(ct).Type = Constraints(ct).describe('identifier');
    SavedData(ct).Data = Constraints(ct).save;
end