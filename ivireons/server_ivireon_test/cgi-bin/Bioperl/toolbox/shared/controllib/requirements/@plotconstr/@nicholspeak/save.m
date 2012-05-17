function SavedData = save(Constr)
%SAVE   Saves constraint data

%   Author(s): Bora Eryilmaz
%   Revised: 
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:28 $

SavedData = struct(...
   'uID', Constr.uID, ...
   'OriginPha', Constr.OriginPha, ...
   'PeakGain',  Constr.PeakGain);
