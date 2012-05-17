function updateStructure(this)
%UPDATESTRUCTURE   Update the structure property.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:24:52 $

if isempty(this.FDesign), return; end

[validStructures, defaultStructure] = getValidStructures(this, 'full');

if ~any(strcmp(this.Structure, validStructures))
    set(this, 'Structure', defaultStructure);
end

% [EOF]
