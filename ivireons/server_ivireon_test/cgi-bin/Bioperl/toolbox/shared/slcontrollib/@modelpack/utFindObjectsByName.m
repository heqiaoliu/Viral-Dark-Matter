function IDs = utFindObjectsByName(allIDs, name)
% UTFINDOBJECTSBYNAME Returns a subset of identifier objects in ALLIDS with
% a full name that begins with NAME.
%
% ALLIDS is an array of @VariableID objects.
% NAME   is a (partial) full name of the objects.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/09/30 00:23:00 $

IDs = [];

for ct = 1:length(allIDs)
  h = allIDs(ct);

  if strmatch( name, h.getFullName )
    IDs = [IDs; h];
  end
end
