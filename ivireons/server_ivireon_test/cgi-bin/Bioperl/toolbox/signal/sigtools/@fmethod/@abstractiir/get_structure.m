function structure = get_structure(this, structure)
%GET_STRUCTURE   PreGet function for the 'structure' property.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:01:15 $

if isempty(structure)
    structure = 'df2sos';
end

% [EOF]
