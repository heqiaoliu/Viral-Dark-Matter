function manager(action, hScope)
%MANAGER Manage all the scope handles.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/11 16:22:37 $

% We need to maintain a list of Scope handles in a function workspace for
% performance reasons.  If these handles are not held in a function
% workspace, MATLAB will have difficulty resolving cyclic references
% causing the Workspace and Simulink sources to run extremely slowly.
% Using APPDATA or anonymous function workspaces does not work.  All
% objects must be eventually connected to the Framework object as well.
persistent allOpenScopes;

switch action
    case 'remove'
        allOpenScopes = setdiff(allOpenScopes, hScope);
    case 'add'
        allOpenScopes = [allOpenScopes hScope];
end

% [EOF]
