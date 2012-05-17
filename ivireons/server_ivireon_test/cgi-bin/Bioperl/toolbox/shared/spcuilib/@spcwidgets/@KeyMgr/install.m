function install(hKeyMgr)
%INSTALL Install key manager into figure.
%   INSTALL(H) installs key manager into figure.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:13 $

set(hKeyMgr.Parent, ...
    'KeyPressFcn', @(hfig,ev)local_KeyPressFcn(hKeyMgr,ev));

%%
function local_KeyPressFcn(hKeyMgr, keyStruct)
% Handle keypresses in HG figure window
% This function handles all the "common" stuff:
%   - weeding out control+ and alt+ key combinations (allows shift)
%   - dispatching to child key handlers

debug = strcmpi(hKeyMgr.Debug,'on');
if strcmpi(hKeyMgr.Enabled,'on')
    % Early exit if CTRL or ALT are pressed, but allow SHIFT.
    % This allows "ctrl+char" menu accelerators to run without
    % unintended side-effects from the keyboard commands below
    %
    ctrl = any(strcmpi(keyStruct.Modifier,'control'));
    alt  = any(strcmpi(keyStruct.Modifier,'alt'));
    if ~ctrl && ~alt
        % Visit each child key handler
        %   Call KeyHitFcn(hKeyHandlerChild) on each child.
        %   If the current child handles the key, the child executes any
        %   related actions then returns a TRUE flag.
        % We stop iterations there, since no other handler should handle
        % the same key.
        %
        detect = false;
        hGroup = hKeyMgr.down; % first child
        while ~isempty(hGroup)
            detect = strcmpi(hGroup.Enabled,'on') && ...
                keyHit(hGroup,keyStruct);
            if detect
                % Display diagnostics here if desired
                if debug
                    fprintf('KeyMgr object debug info\n');
                    fprintf('Key press handled by group "%s"\n', ...
                        hGroup.Name);
                    disp(keyStruct);
                    fprintf('\n');
                end
                break % we're done once any detection is made
            end
            hGroup = hGroup.right; % next child
        end
        if ~detect && debug
            fprintf('KeyMgr object debug info\nKey press not handled\n');
            disp(keyStruct);
            fprintf('\n');
        end
    end
else
    if debug
        fprintf('KeyMgr object debug info\nKeyMgr disabled\n\n');
    end
end

% [EOF]
