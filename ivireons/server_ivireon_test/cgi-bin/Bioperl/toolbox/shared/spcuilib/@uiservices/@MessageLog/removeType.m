function hMessageLog = removeType(hMessageLog,mType)
%REMOVETYPE Remove all messages of chosen type from message log.
%  removeType(H,TYPE) removes all messages of type TYPE from log
%  using case-independent matching of string TYPE.
%  Does not affect linked logs.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:45 $

% Changing child items (including removing them) invalidates
% the MergedLog cache:
invalidateMergedLog(hMessageLog);

iterator.visitImmediateChildrenBkwd(hMessageLog,@local_disconnectByType);

% Send event in case someone else is watching our list
% (such as if we're a LinkedLog)
send(hMessageLog,'LogUpdated');

    % Nested function provides mType as global variable
    function local_disconnectByType(hMessageItem)
        % Disconnect children with specified Type
        if strcmpi(hMessageItem.Type, mType)
            disconnect(hMessageItem);
        end
    end
end

% [EOF]
