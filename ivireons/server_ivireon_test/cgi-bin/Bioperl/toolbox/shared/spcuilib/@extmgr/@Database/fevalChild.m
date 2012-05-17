function varargout = fevalChild(this, fcn, checkFcn)
%FEVALCHILD Evaluate the function on each of the objects children.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:47 $

% Use the iterator package function for the implement.
if nargin > 2
    if nargout == 0
        iterator.visitImmediateChildrenConditional(this, fcn, checkFcn);
    else
        varargout = {iterator.visitImmediateChildrenConditional(this, fcn, checkFcn)};
    end
else
    if nargout == 0 
        iterator.visitImmediateChildren(this, fcn);
    else
        varargout = {iterator.visitImmediateChildren(this, fcn)};
    end
end

% [EOF]
