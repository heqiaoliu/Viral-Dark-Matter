function load(Constr,SavedData)
%LOAD  Reloads saved constraint data.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:31:49 $

if isfield(SavedData,'uID')
   Constr.setUID(SavedData.uID);
   SavedData = rmfield(SavedData,'uID');
end

%Call set for all public properties
set(Constr,SavedData);
