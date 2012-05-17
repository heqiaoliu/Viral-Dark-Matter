function setCurrentConfiguration(this)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2006/01/26 01:47:09 $

this.DesignViewsTableData = cell(this.Handles.TablePanel.getViewTableData);
DesignViewsTableData = this.DesignViewsTableData;
sisodb = this.SISODB;
L = this.SISODB.LoopData.L;

TunedLoopNameList = get(L,{'Name'});


PlotEditors = this.SISODB.PlotEditors;
set(PlotEditors,'visible','off')

for ct = 1:6;
    PlotType = DesignViewsTableData{ct,3};
    if ~strcmp(PlotType,'None')
        switch PlotType;
            case 'Root Locus'
                EditorClass = 'sisogui.rleditor';
            case 'Open-Loop Bode'
                EditorClass = 'sisogui.bodeditorOL';
            case 'Nichols'
                EditorClass = 'sisogui.nicholseditor';
            case 'Closed-Loop Bode'
                EditorClass = 'sisogui.bodeditorF';
        end

        idxL = find(strcmp(DesignViewsTableData{ct,2},TunedLoopNameList));
        
        if ~isempty(sisodb.PlotEditors)
            Editor = find(sisodb.PlotEditors,'-isa',EditorClass,'EditedLoop',idxL);
            if isempty(Editor)
                % First look for free editor of the right type
                Editor = find(sisodb.PlotEditors,'-isa',EditorClass,'Visible','off');
                if isempty(Editor)
                    % Create new editor
                    Editor = addeditor(sisodb,EditorClass,idxL);
                else
                    Editor = Editor(1);
                    Editor.EditedLoop = idxL;
                end
            end
        else
            % Create new editor
            Editor = addeditor(sisodb,EditorClass,idxL);
        end
        % Make editor visible
        set(Editor,'Visible','on');
    end
end

