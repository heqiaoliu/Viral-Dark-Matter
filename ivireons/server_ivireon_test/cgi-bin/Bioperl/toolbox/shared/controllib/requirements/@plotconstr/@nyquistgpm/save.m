function SavedData = save(Constr)
%SAVE   Saves constraint data

%   Author(s): A. Stothert
%   Revised: 
%   Copyright 2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:50:02 $

PhaseEnabled = false;
GainEnabled  = false;
gainphase = Constr.Data.Type;
if strcmp(gainphase,'phase') || strcmp(gainphase,'both')
    PhaseEnabled = true;
end
if strcmp(gainphase,'gain') || strcmp(gainphase,'both')
    GainEnabled = true;
end
SavedData = struct(...
   'uID', Constr.uID, ...
   'MarginGain',  Constr.Data.yCoords, ...
   'MarginPha', Constr.Data.xCoords,...
   'PhaseEnabled', PhaseEnabled, ...
   'GainEnabled', GainEnabled);
