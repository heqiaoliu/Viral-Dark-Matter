function NormalModeVisibility(modelName, varargin)
% SIMULINK.MODELREFERENCE.NORMALMODEVISIBILITY opens the GUI for editing 
% Model block Normal Mode Visibility
%
% Simulink.ModelReference.NormalModeVisibility(name) opens the GUI for editing
% Model block Normal Mode Visibility for the specified model.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
    mlock;
    
    if(isempty(varargin))
        command = 'Open';
    else
        command = varargin{1};
    end
    
    loc_doCommand(modelName, command);

end


function loc_doCommand(modelName, command)
    persistent EDITORS;
    
    if(isempty(EDITORS))
        EDITORS = containers.Map('KeyType', 'char', 'ValueType', 'any');
    end
    
    switch command
        case {'Open'}
            found = [];
            
            if(EDITORS.isKey(modelName))
                found = DAStudio.ToolRoot.getOpenDialogs(EDITORS(modelName));
            end
            
            if(isempty(found))
                try
                    ui = Simulink.ModelBlockNormalModeVisibilitySelectorUI(modelName);
                    EDITORS(modelName) = ui.m_root.getDialogProxy();
                catch me
                    % Ignore this exception since it means the hierarchy explorer 
                    % was closed when it wasn't ready.  This is expected if the user
                    % presses cancel before all the nodes have been created.
                    if(~ isequal(me.identifier, ...
                                'Simulink:modelReference:HierarchyExplorerClosedWhenNotReady'))
                        rethrow(me);
                    end
                end

            else
                found.getSource.m_main.show;
            end
         
            
            
        case {'Close'}
            if(EDITORS.isKey(modelName))
                EDITORS.remove(modelName);
            end
            
            
            
      otherwise
        if(ischar(command))
            DAStudio.error('Simulink:modelReference:NormalModeVisibilityUnexpectedCommand', command);
        else
            DAStudio.error('Simulink:modelReference:NormalModeVisibilityUnexpectedCommandType');
        end            
    end
end

