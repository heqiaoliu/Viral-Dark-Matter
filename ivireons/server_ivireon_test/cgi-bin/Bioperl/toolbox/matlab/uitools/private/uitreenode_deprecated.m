function node = uitreenode_deprecated(value, string, icon, isLeaf)
% This function is undocumented and will change in a future release

% Copyright 2003-2007 The MathWorks, Inc.

% Warn that this old code path is no longer supported.
warn = warning('query', 'MATLAB:uitreenode:DeprecatedFunction');
if isequal(warn.state, 'on')
    warning('MATLAB:uitreenode:DeprecatedFunction', ...
        'This implementation of uitreenode has been deprecated and is no longer supported.');
end

import com.mathworks.hg.peer.UITreeNode;
node = handle(UITreeNode(value, string, icon, isLeaf));
schema.prop(node, 'UserData', 'MATLAB array');
