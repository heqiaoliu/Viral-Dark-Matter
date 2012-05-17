function index = getindex(hCoeff)
%GETINDEX Returns the selected index to the popup
%   GETINDEX(hCoeff) Returns the index to the popup associated with the
%   selected Filter Structure.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:19:31 $

% This will be a private method

s_struct = get(hCoeff,'SelectedStructure');
if isempty(s_struct)
    index = [];
else
    a_struct = get(hCoeff,'AllStructures');
    index = find(strcmpi(s_struct, a_struct.strs));
end

% [EOF]
