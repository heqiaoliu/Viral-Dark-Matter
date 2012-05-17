function setstate(hSB,state)
%SETSTATE Sets the state of sidebar.
%   SETSTATE(hSB, STATE) Sets the state of the sidebar associated with
%   hSB.  This state is all the information necessary to recreate the
%   current state of the sidebar object.
%
%   See also GETSTATE.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2008/04/21 16:31:45 $

hFig      = get(hSB,'FigureHandle');

p_state = [];

% Set the current panel
index = string2index(hSB, state.currentpanel);
set(hSB,'CurrentPanel',index);

names = fieldnames(rmfield(state,'currentpanel'));

for i = 1:length(names)
    try
        hPanel = getpanelhandle(hSB, names{i});
    catch ME 
    end
    % If GETPANELHANDLE returned 0, then the panel does not exist
    if ~isequal(hPanel,0),
        if isempty(hPanel),
            hPanel = constructAndSavePanel(hSB, names{i});
        end
        
        % If the panel information is a structure, its fields contain function handles.
        % xxx
        if isstruct(hPanel),
            p_state = getfield(state, names{i});
            feval(hPanel.setstate, hFig, p_state);
        else
            p_state = getfield(state, names{i});
            setstate(hPanel, p_state);
        end
        
    % If GETPANELHANDLE errored because of unknown fields in structure (i.e. panels), warn
    elseif ~isempty(strfind(lower(ME.message), ...
            sprintf('tag does not match any currently installed panels.'))),
        warning(generatemsgid('GUIWarn'),['File contains information not usable by this version of ' ...
                'FDATool.' char(10) 'Loading remaining data.']);
    end
end

% [EOF]
