function y = visitImmediateChildren(h,fcn)
%visitImmediateChildren Apply function to first-level children.
%   Visit first-level child nodes and apply function to each.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:21:42 $

if nargout==0
    hc=h.down; % first child
    while ~isempty(hc)
        fcn(hc);
        hc=hc.right;
    end
else
    N = iterator.numImmediateChildren(h);
    y = cell(1,N);
    i=0;
    hc=h.down; % first child
    while ~isempty(hc)
        i=i+1;
        y{i} = fcn(hc);
        hc=hc.right;
    end
end

% [EOF]
