function load(Constr,SavedData)
%LOAD  Reloads saved constraint data.

% Author(s): A. Stothert 08-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:05 $

if isfield(SavedData,'uID')
   Constr.setUID(SavedData.uID);
   SavedData = rmfield(SavedData,'uID');
end

%Set gain and phase margin, x=phase, y=gain as on nichols plot

%Check we may have data from an old nicholsgain/nicholsphase constraint
if isfield(SavedData,'MarginPha')
    Constr.Data.xCoords = SavedData.MarginPha;
    Constr.Data.Type = 'phase';
end
if isfield(SavedData,'MarginGain')
    Constr.Data.yCoords = SavedData.MarginGain;
    Constr.Data.Type = 'gain';
end
if isfield(SavedData,'OriginPha')
    Constr.Origin = SavedData.OriginPha;
end

%Check for data fields from nicholsgpm constraint
if isfield(SavedData,'Type')
    Constr.Data.Type = SavedData.Type;
end
if isfield(SavedData,'Gain')
    Constr.Data.yCoords = SavedData.Gain;
    Constr.Data.yUnits  = SavedData.GainUnits;
end
if isfield(SavedData,'Phase')
    Constr.Data.xCoords = SavedData.Phase;
    Constr.Data.xUnits  = SavedData.PhaseUnits;
end