function pCheckAndSetInteractiveType(obj, type)
; %#ok Undocumented
%pCheckCorrectInteractiveType Check if type can make a call

%   Copyright 2007 The MathWorks, Inc.

currentType = obj.CurrentInteractiveType;
% Cannot use this to set type to none
if ~strcmp(type, 'none') 
    if strcmp(type, currentType)
        return
    end
    if strcmp(currentType, 'none')
        obj.CurrentInteractiveType = type;
        obj.Tag = ['Created_by_' type];
        return
    end
end

error('distcomp:interactive:InvalidCallState', ...
    ['You cannot use %s when %s currently has an open session running\n' ...
     'Use %s close to finish the existing session before using %s'], type, currentType, currentType, type);