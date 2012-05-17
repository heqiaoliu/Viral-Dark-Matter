function y = visitImmediateChildrenConditional(h,fcn,condFcn)
%visitImmediateChildrenConditional Optionally apply function to children.
%   visitImmediateChildrenConditional(H,FCN,CONDFCN) visits all first-
%   level child nodes, and if the condition function CONDFCN applied to
%   the node returns true, applies function FCN to the node.
%
%   y = visitImmediateChildrenConditional(...) captures result of each
%   application of FCN, returning a vector cell-array.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/09/09 21:29:05 $

if nargout==0
    hc=h.down; % first child
    while ~isempty(hc)
        if condFcn(hc)
            fcn(hc);
        end
        hc=hc.right;
    end
else
    N = iterator.numImmediateChildren(h);
    y = cell(1,N); % maximum allocation
    i=0;
    hc=h.down; % first child
    while ~isempty(hc)
        if condFcn(hc)
            i=i+1;
            y{i} = fcn(hc);
        end
        hc=hc.right;
    end
    y = y(1:i);  % remove unused entries
end

% [EOF]
