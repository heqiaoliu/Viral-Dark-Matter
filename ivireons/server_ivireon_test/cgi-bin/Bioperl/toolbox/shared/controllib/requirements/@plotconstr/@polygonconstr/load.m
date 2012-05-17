function load(Constr,SavedData)
%LOAD  Reloads saved constraint data.

%   Author(s): A. Stothert
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:45 $

if isa(Constr,'plotconstr.bodegain') && ...
   isfield(SavedData,'Frequency')
   %Loading old constraint type, create temporary SavedData Structure
   tSaved = struct(...
      'xCoords',SavedData.Frequency,...
      'yCoords',SavedData.Magnitude,...
      'xUnits', 'dB',...
      'yUnits', 'rad/sec', ...
      'Linked', [],...
      'SelectedEdge', 1, ...
      'Type', SavedData.Type, ...
      'OpenEnd', [false false]);
   SavedData = tSaved;
end

if isfield(SavedData,'OpenEnd')
   Constr.setData('OpenEnd',SavedData.OpenEnd);
   SavedData = rmfield(SavedData,'OpenEnd');
end
if isfield(SavedData,'uID')
   Constr.setUID(SavedData.uID);
   SavedData = rmfield(SavedData,'uID');
end

%Set public properties
set(Constr,SavedData);