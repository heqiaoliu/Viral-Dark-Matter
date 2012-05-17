function load(Constr,SavedData)
%LOAD  Reloads saved constraint data.
%
 
% Author(s): A. Stothert 23-Dec-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:31 $

if isfield(SavedData,'uID')
   Constr.setUID(SavedData.uID);
   SavedData = rmfield(SavedData,'uID');
end

%Set gain and phase margin
Constr.Data.xCoords = SavedData.MarginPha;
Constr.Data.yCoords = SavedData.MarginGain;

%Set type based on gain/phase enabled
if SavedData.PhaseEnabled && SavedData.GainEnabled
     Constr.Data.Type = 'both';
elseif SavedData.PhaseEnabled
     Constr.Data.Type = 'phase';
elseif SavedData.GainEnabled
     Constr.Data.Type = 'gain';
else
    Constr.Data.Type = 'none';
end
