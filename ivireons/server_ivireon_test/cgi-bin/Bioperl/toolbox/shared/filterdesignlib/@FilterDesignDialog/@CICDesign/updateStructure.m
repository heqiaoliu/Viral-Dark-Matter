function updateStructure(this)
%UPDATESTRUCTURE   

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:17 $

if strcmpi(this.FilterType, 'decimator')
    structtype = 'cicdecim';
else
    structtype = 'cicinterp';
end

set(this, 'Structure', structtype);

% [EOF]
