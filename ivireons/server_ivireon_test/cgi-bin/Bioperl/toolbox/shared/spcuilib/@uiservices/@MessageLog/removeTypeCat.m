function hMessageLog = removeTypeCat(hMessageLog,mType,mCat)
%REMOVETYPECAT Remove all messages of chosen type and category.
%  removeTypeCat(H,TYPE,CAT) removes all messages of type TYPE
%  and category CAT from log using case-independent matching of string.
%  Note that 'all' can be used for TYPE and CAT and matches all entries.
%  Does not affect linked logs.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:46 $

allType = strcmpi(mType,'all');
allCat  = strcmpi(mCat,'all');

% Changing child items (including removing them) invalidates
% the MergedLog cache:
invalidateMergedLog(hMessageLog);

iterator.visitImmediateChildrenBkwd(hMessageLog,@local_disconnectByTypeCat);

% Send event in case someone else is watching our list
% (such as if we're a LinkedLog)
send(hMessageLog,'LogUpdated');

    % Nested function provides mType, mCat, allType, and allCat
    % as global variables
    function local_disconnectByTypeCat(hMessageItem)
        % Disconnect children with specified Type and Category
        if (allType || strcmpi(hMessageItem.Type,mType)) && ...
           (allCat  || strcmpi(hMessageItem.Category,mCat))
            disconnect(hMessageItem);
        end
    end
end

% [EOF]
