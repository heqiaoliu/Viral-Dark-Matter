function [hChild,varargout] = visitImmediateChildConditional(h,execFcn,condFcn)
%visitImmediateChildConditional Apply method to first matching child.
%   hChild = visitImmediateChildConditional(h,execFcn,condFcn) visits each
%   first-level child node from left to right, applying execFcn to the
%   first child that causes condFcn to return TRUE.
%
%   The handle of this child is returned, or empty if no match is found.
%   condFcn must return a logical value.
%
%   [hChild,V1,V2,...] = visitImmediateChildConditional(...) optionally
%   returns values V1, V2, ..., returned by execFcn.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:48 $

hChild = h.down; % first child
while ~isempty(hChild)
    if condFcn(hChild)
        if nargout>1
            [varargout{:}] = execFcn(hChild);
        else
            execFcn(hChild);
        end
        break % we're done!
    end
    hChild = hChild.right; % next child
end

% When code falls through, either:
%  - no match was found,
%    in which case we return with hChild set to empty
%  - match was found,
%    in which case the desired hChild is returned

% [EOF]
