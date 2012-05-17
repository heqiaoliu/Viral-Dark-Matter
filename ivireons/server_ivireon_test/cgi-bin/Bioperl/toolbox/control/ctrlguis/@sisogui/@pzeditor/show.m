function show(Editor, Target, idxC)
%SHOW  Brings up and targets PZ editor.

%   Author: P. Gahinet 
%   Revised: C. Buhr, R Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.7.4.6 $  $Date: 2007/02/06 19:50:58 $

if ~strcmp(Editor.EditMode,'off')
    % Set index of currently edited compensator
    Editor.idxCold = Editor.idxC;
    Editor.idxC = idxC;
    Editor.idxPZ = [];
    % Set list of edited compensators
    % update the compensator list which excludes pure gain elements
    bool = isGainBlock(Target);
    Editor.GainList = Target(bool);
    Editor.CompList = Target(~bool);
    % rebuild the combo box
    ComboAll = Editor.Handles.ComboDispHandles.CompComboBox;
    % disable the combo callback
    hdl = Editor.Handles.ComboDispHandles.CompComboBoxListener;
    hdl.Enabled = 'off';
    % update combo
    awtinvoke(ComboAll,'removeAllItems()');
    for ct = 1:length(Editor.CompList)
        if isempty(Editor.CompList(ct).Name)
            awtinvoke(ComboAll,'addItem(Ljava/lang/Object;)',Editor.CompList(ct).Identifier);
        else
            awtinvoke(ComboAll,'addItem(Ljava/lang/Object;)',Editor.CompList(ct).Name);
        end
    end
    if ~isempty(Editor.GainList)
        if length(Editor.GainList)==1
            if isempty(Editor.GainList.Name)
                awtinvoke(ComboAll,'addItem(Ljava/lang/Object;)',Editor.GainList.Identifier);
            else
                awtinvoke(ComboAll,'addItem(Ljava/lang/Object;)',Editor.GainList.Name);
            end
        else
            awtinvoke(ComboAll,'addItem(Ljava/lang/Object;)',sprintf('All Gain Blocks'));
        end
    end
    % initialize panels
    if (Editor.idxC-1)>=0
        awtinvoke(ComboAll,'setSelectedIndex(I)',Editor.idxC-1);
    end
    % Clear the event queue
    drawnow
    % Renable the callback
    hdl.Enabled = 'on';
  
    % Make figure visible & bring to front
    if ~Editor.isVisible && ~isempty(Editor.Parent.DesignTask)
        Editor.Parent.DesignTask.show('PZEditor');
    end
end
