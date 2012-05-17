function setSpecsSafely(this, fdesignobj, spec)
%SETSPECSSAFELY Set specs safely 
% In the Simulink operating mode the saved specs could require a Filter
% Design Toolbox license that may not be available (read-only mode)

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:38:19 $

entries = set(fdesignobj,'Specification');
if any(strcmpi(spec,entries)),
    set(fdesignobj,'Specification',spec);
end

% [EOF]
