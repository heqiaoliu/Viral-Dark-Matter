function SavedData = save(Constr)
%SAVE  Saves constraint data

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:27 $

SavedData = struct(...
   'uID', Constr.uID, ...
   'Frequency',Constr.Frequency,...
   'Type',Constr.Type);

    