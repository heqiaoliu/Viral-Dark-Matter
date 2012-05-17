function hMessageLog = removeCat(hMessageLog,mCat)
%REMOVECAT Remove all messages of chosen category from message log.
%  removeCat(H,CAT) removes all messages of category CAT from log
%  using case-independent matching of string CAT.
%  Does not affect linked logs.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:44 $

% Changing child items (including removing them) invalidates
% the MergedLog cache:
invalidateMergedLog(hMessageLog);

iterator.visitImmediateChildrenBkwd(hMessageLog,@local_disconnectByCat);

% Send event in case someone else is watching our list
% (such as if we're a LinkedLog)
send(hMessageLog,'LogUpdated');

    % Nested function to provide mCat as global variable
    function local_disconnectByCat(hMessageItem)
        % Disconnect children with specified Category
        if strcmpi(hMessageItem.Category,mCat)
            disconnect(hMessageItem);
        end
    end
end

% [EOF]
