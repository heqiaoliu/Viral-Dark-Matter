function setupFDesignTypes(this)
%SETUPFDESIGNTYPES Setup the FDesign Types

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:42:31 $

fd = get(this, 'FDesign');
if ~isempty(fd)
    fd.Type = this.Type;
end

% [EOF]
