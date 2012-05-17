function updateMethod(this)
%UPDATEMETHOD   Update the method.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:23 $

if isempty(this.FDesign), return; end

methods = getValidMethods(this);
if isempty(methods)
   return
end
if isempty(find(strcmpi(this.DesignMethod, methods), 1))
    set(this, 'DesignMethod', methods{1});
else
    updateDesignOptions(this);
end

% [EOF]
