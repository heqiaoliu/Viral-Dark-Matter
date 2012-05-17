function varargout = validateSource(~, ~)
%VALIDATESOURCE Validate the source will work for this visual.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:44:19 $

if nargout
    varargout = {true, MException.empty};
end

% [EOF]
