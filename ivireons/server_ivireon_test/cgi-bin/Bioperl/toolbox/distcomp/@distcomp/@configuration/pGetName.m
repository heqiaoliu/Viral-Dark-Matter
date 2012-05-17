function name = pGetName(obj, name) %#ok Not using input name.
; %#ok Undocumented
%pGetName Get the name of the configuration.
%
%  name = config.pGetName()

%  Copyright 2007 The MathWorks, Inc.

% The name is stored in the ActualName property.
name = obj.ActualName;
    
