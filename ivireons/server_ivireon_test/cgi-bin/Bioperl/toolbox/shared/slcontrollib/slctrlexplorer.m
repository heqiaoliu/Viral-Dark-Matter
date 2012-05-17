function [F, W, M] = slctrlexplorer(varargin)
% SLCTRLEXPLORER Method to start or interact with the Tree Explorer for
% Simulink-based control products.
%
% [F, W, M] = SLCTRLEXPLORER returns the handles to the frame, root
% (workspace) node, and the tree manager, constructing them if necessary.

% Author(s): B. Eryilmaz, J. Glass
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/10/15 23:28:08 $

% Explorer tree manager handle
mlock
persistent MANAGER;

% Check for valid platform for Java Swing
if ~usejava('Swing')
    ctrlMsgUtils.error('SLControllib:explorer:JavaNotSupportedOnThisPlatform');
end

if (nargin == 1) && (strcmp(varargin{1},'getWithoutCreating'))
    if isa(MANAGER,'explorer.TreeManager')
        M = MANAGER;
        F = MANAGER.Explorer;
        W = MANAGER.Root;
    else
        M = [];
        F = [];
        W = [];
    end
else
    % Check for a valid tree manager.
    if isempty(MANAGER) || ~ishandle(MANAGER)
        % If not, create tree manager.
        MANAGER = explorer.TreeManager;
    end

    % Output arguments
    M = MANAGER; % Workaround for returned persistent variables
    F = MANAGER.Explorer;
    W = MANAGER.Root;
end
