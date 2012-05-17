function returnTree = createTreeTable(this, Parent, treeTableModel, varargin)

    % Copyright 2010 The MathWorks, Inc.
    
    if isempty(varargin)
        returnTree.TT  = javaObjectEDT('com.jidesoft.grid.TreeTable');
    else
        returnTree.TT  = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomTreeTable');
    end
    
    returnTree.TT.setShowTreeLines(false);
    returnTree.ScrollPane = javaObjectEDT('javax.swing.JScrollPane');
    returnTree.ScrollPane.getViewport.setView(returnTree.TT);
    %             Parent.add(returnTree.ScrollPane);
    [~, returnTree.container] = javacomponent(returnTree.ScrollPane,...
                                              [0 0 1 1], Parent);
    returnTree.TT.setModel(treeTableModel);
    returnTree.TT.setRowHeight(25);
    returnTree.ScrollPane.getViewport.setBackground(java.awt.Color.white);
    returnTree.TT.setAutoResizeMode(com.jidesoft.grid.TreeTable.AUTO_RESIZE_OFF);    
    returnTree.TT.getTableHeader.setReorderingAllowed(false);
    returnTree.TT.setShowSortOrderNumber(false);
    returnTree.TableCallback = handle(returnTree.TT,'callbackproperties');
end

