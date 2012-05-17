function importdata(Editor)
%IMPORTDATA  Import compensator data into pzeditor whenever loopdata is 
%changed

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.8.4.6 $  $Date: 2007/02/06 19:50:55 $

if ~strcmp(Editor.EditMode, 'off')
    % populate gainlist and complist from the handles stored in LoopData.C 
    bool = isGainBlock(Editor.LoopData.C);
    % update the pure gain list from listener
    Editor.GainList = Editor.LoopData.C(bool);
    % update the compensator list which excludes pure gain elements
    Editor.CompList = Editor.LoopData.C(~bool);
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
    % initialize the component selection to the first
    Editor.idxC = 1;
    Editor.idxCold = 1;
    % initialize panels
    awtinvoke(ComboAll,'setSelectedIndex(I)',Editor.idxC-1);
    % Clear the event queue
    drawnow
    % Renable the callback
    hdl.Enabled = 'on';
end
