function mouseClickedActions(h,tables,Ind,MouseEvent)
%Highlight the simulink block from the block-path, if the user clicks on the
%hyperlink.
% Also, deselect all selection from all other tables in the panel.
%   tables is a java array of all the tables.
%   Ind is the index of the table who row was selected.
% MouseEvent: mouse event
% h: @simulinkTsparentNode handle

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/07/18 18:44:16 $


% clear old selections from all tables except the one whos row was selected
for k = 1:length(tables)
    if k~=Ind
        awtinvoke(tables(k),'clearSelection');
    end
end

BTNextract = h.Handles.BTNextract;


if strcmpi(tables(Ind).getModel.TableModelNameTag,'Simulink Time Series')
    set(BTNextract,'enable','off')
else
    set(BTNextract,'enable','on')
end

%h.Handles.SelectedTable = handle(h.Handles.ModelTables(k),'callbackproperties');
h.Handles.SelectedTable = tables(Ind);

import java.awt.geom.Point2D;
Col = h.Handles.SelectedTable.columnAtPoint(MouseEvent.getPoint);
if Col==2 %block path column (java index starts at 0)
    Row = h.Handles.SelectedTable.rowAtPoint(MouseEvent.getPoint);
    if Row>=0
        str = h.Handles.SelectedTable.getModel.getValueAt(Row,2);
        loc = strfind(str,'"');
        if length(loc)<2
            return
        end
        str = str(loc(1)+1:loc(2)-1);
        try
            dynamicHiliteSystem(str);
        catch me
            errordlg(me.message,'Time Series Tools','modal');
            return
        end
    end
end