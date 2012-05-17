function s = saveobj(~)
%SAVEOBJ  Save this object.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:10:49 $

warning('signal:fvtool:NotSerializable', 'FVTool is not serializable.');

% Something must be returned to avoid the default object load.
s.EmptyField = [];

% [EOF]
