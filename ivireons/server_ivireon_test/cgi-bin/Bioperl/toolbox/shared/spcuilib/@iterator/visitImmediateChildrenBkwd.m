function y = visitImmediateChildrenBkwd(h,fcn)
%visitImmediateChildrenBkwd Apply function to reverse-order children.
%   Visit first-level child nodes in reverse order, and apply
%   specified function to each.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:21:43 $

% NOTE: We cache the "left" child as we visit the current child,
%       in case the user-specified operation being performed is in
%       fact a "disconnect" operation.  That's because disconnecting the
%       current child removes knowledge of its (former) left-hand sibling.

if nargout==0
    hc=h.down('last'); % last child
    while ~isempty(hc)
        hprev = hc.left;
        fcn(hc);
        hc=hprev;
    end
else
    N = iterator.numImmediateChildren(h);
    y = cell(1,N);
    hc = h.down; % first child
    i=0;
    while ~isempty(hc)
        hprev = hc.left;
        i=i+1;
        y{i} = fcn(hc);
        hc=hprev;
    end
end

% [EOF]
