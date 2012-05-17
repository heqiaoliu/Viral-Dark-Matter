classdef TablePanelController < hgsetget
    %TABLEPANELCONTROLLER A controller for sortable and hierarchical tables
    %supporting logical and string cells.
    %
    %
    %
    % How to use TablePanelController:
    %
    % create the table by passing in cell array of strings or logicals.
    % There will be one column in the table for each column of the cell array
    %
    % controller = TablePanelController({ 'a' 'b'; 'c' 'd'},...
    %                                   {'column1', 'column2'}, [true true],...
    %                                   'ComponentNameForQeTests')
    % will create the following java table
    %
    %  ------------------------------
    %  | column1      | column2     |
    %  ------------------------------
    %  |      a       |       b     |
    %  ------------------------------
    %  |      c       |       d     |
    %  ------------------------------
    %
    %  both the columns of the table will be editable.
    %
    % In order to embed the table in a HG ui panel, use javacomponent.
    %  f = figure('units', 'pixels', 'position', [200 200 400 400]);
    %  [jcomp hgcomp] = javacomponent(controller.getJavaComponent,...
    %                               [50 50 200 200], f);
    %
    % In order to embed the table in a JAVA Container, add the
    % JavaComponent to the container.
    % TMStyleGuidePanel().addLine(controller.getJavaComponent);
    %
    % The table notifies listeners of different events on user actions. Each
    % event has event related data associated with it.
    %
    % TablePanelController can also be used to create a hierarchical table
    % which allows for expandable child tables to exist for each row of the
    % main table. All other aspects of the table functioning as a
    % sortable table remain the same. An example hierarchical table look as
    % follows:
    %
    %  --------------------------------
    %    | column1      | column2     |
    %  --------------------------------
    %  |+|      a       |       b     |
    %  --------------------------------
    %  |+|      c       |       d     |
    %  --------------------------------    
    %
    % Expanding the '+' will show an independent child table attached to
    % the given row.
    %
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.3 $ $Date: 2010/05/10 17:38:23 $
    
    properties(SetAccess='private', GetAccess='private')
        % The java TablePanel object containing the table.
        TablePanel = [];
        
        % Matrix of listeners to callbacks. The listeners are put in this
        % matrix to prevent them from being deleted when they go out of scope.
        WidgetListeners = [];
    end
    
    properties (Constant)
        % In order to add a separator to the context menu item, this
        % constant string should be passed in as an argument to
        % setMenuItems.
        MENU_SEPARATOR = 'TablePanelController.Separator';
        
        % In order to add a Cut,Copy,Paste items to the context menu item,
        % this constant string should be passed in as an argument to
        % setMenuItems. The ClipboardRequested event is poseted each time
        % user selects the cut,copy,paste menu items.
        CUT_COPY_PASTE = 'TablePanelController.CutCopyPaste';
    end
    
    events
        % The event data for all these events is an object of class
        % internal.event.WidgetEventData . The event data is a structure
        % contained in the Data field of the class. The fields of the
        % structure depend on the event.
        
        % This event is posted each time user selects a new row in the table.
        % The event data is structure containing following fields -
        % RowIndex - Index of the selected row
        RowSelected;
        
        % This event is posted each time user edits a cell in the table.
        % The event data is structure containing following fields -
        % RowIndex - Index of the selected row
        % ColumnIndex - Index of the selected column
        % OldValue - previous value in the cell
        % NewValue - new value in the cell
        CellEdited;
        
        % This event is posted each time user presses a key while the
        % table has focus
        % The event data is structure containing following fields -
        % RowIndex - Index of the selected row
        % ColumnIndex - Index of the selected column
        % KeyChar - character of the key pressed, e.g. 'a', 'e' etc.
        % KeyText - a friendly description of the keys, e.g. 'Delete' for
        % delete etc.
        % Modifiers - contains string if modifier is selected as part of key
        % event - 'Alt', 'Ctrl', 'Shift' etc.
        KeyPressed;
        
        % This event is posted each time user selects a menu item
        % The event data is structure containing following fields -
        % RowIndex - Index of the selected row
        % ColumnIndex - Index of the selected column
        % SelectedMenuName - Name of the selected menu item
        MenuSelected;
        
        % This event is posted each time user preseese delete key
        % The event data is structure containing following fields -
        % RowIndex - Index of the deleted row
        RowDeletionRequested;
        
        
        % This event is posted each time user presses the key combination
        % for cut, copy, paste or selects cut, copy, paste menu item from
        % contect menu(when present).
        % The event data is structure containing following fields -
        % RowIndex - Index of the selected row
        % Type - a string 'Cut', 'Copy' or 'Paste' indicating the action
        % invoked by the user.
        ClipboardRequested;
    end
    % ---------------------------------------------------------------------
    methods(Access = 'public')
        function obj = TablePanelController(data, columnnames, editable, componentname, varargin)
            % OBJ = TABLEPANELCONTROLLER(DATA, COLUMNNAMES, EDITABLE)
            %  creates a table with one column for each column in DATA.
            %
            % DATA a cell array of strings or boolean that you want to
            % display in the table. All the data in a single column of the
            % table must have the same data-type i.e all booleans or all
            % strings.
            %
            % COLUMNNAMES a string cell array containing column names. the
            % names will
            % appear in the header of the column
            %
            % EDITABLE a logical matrix specifying if a column is editable
            %
            % COMPONENTNAME is a string used to name java components. The
            % panel and table will be given the following suffix -
            %        JavaComponent = [qename '.panel']
            %        Table         = [qename '.table']
            %
            % VARARGIN is used to declare what type of table is being
            % created. If the table is a standard, sortable table, there
            % should be no VARARGIN argument. If the table being
            % constructed is hierarchical, then a VARARGIN should be
            % provided. It is recommended to pass the string 'Hierarchical'
            % as VARARGIN in this case.
            
            assert(ischar(componentname) , 'componentname must be string.');
            
            % store the matlab data in a java list.
            javaList = obj.convertToJavaList(data);
            
            % if the data is empty; then the java list will be empty.
            % add at least an empty list to indicate that the columns
            % are empty
            if(javaList.isEmpty())
                for index = 1 : length(columnnames)
                    javaList.add(java.util.ArrayList());
                end
            end
            
            % create a ColumnInfo object for each column.
            columnInfoList = java.util.ArrayList;
            for index = 1 : length(columnnames)
                columnInfoList.add(...
                    com.mathworks.toolbox.testmeas.tmswing.table.ColumnInfo(...
                    javaList.get(obj.getJavaIndex(index)),...
                    columnnames{index},...
                    editable(index)));
            end
            
            % Create the java object. If a variable argument is provided,
            % then create a hierarchical table.
            if nargin == 4
                obj.TablePanel = ...
                    com.mathworks.toolbox.testmeas.tmswing.table.SortableTablePanel(columnInfoList, componentname);
            else
                obj.TablePanel = ...
                    com.mathworks.toolbox.testmeas.tmswing.table.HierarchicalTablePanel(columnInfoList, componentname);
            end
            
            % register listeners
            callback = handle(obj.TablePanel.getRowSelectedCallback);
            listener = handle.listener(callback, 'delayed', @(src, data) handleRowSelected(obj, data.JavaEvent));
            obj.WidgetListeners = [obj.WidgetListeners listener];
            
            callback = handle(obj.TablePanel.getKeyPressedCallback);
            listener = handle.listener(callback, 'delayed', @(src, data) handleKeyPressed(obj, data.JavaEvent));
            obj.WidgetListeners(end + 1) = listener;
            
            callback = handle(obj.TablePanel.getCellEditedCallback);
            listener = handle.listener(callback, 'delayed', @(src, data) handleCellEditedCallback(obj, data.JavaEvent));
            obj.WidgetListeners(end + 1) = listener;
            
            callback = handle(obj.TablePanel.getMenuSelectedCallback);
            listener = handle.listener(callback, 'delayed', @(src, data) handleMenuSelected(obj, data.JavaEvent));
            obj.WidgetListeners(end + 1) = listener;
            
            callback = handle(obj.TablePanel.getClipboardCallback);
            listener = handle.listener(callback, 'delayed', @(src, data) handleClipboardCallback(obj, data.JavaEvent));
            obj.WidgetListeners(end + 1) = listener;
        end
        
        function javaComponent = getJavaComponent(obj)
            % JAVACOMPONENT GETJAVACOMPONENT - returns the java component containing the
            % table object.
            
            javaComponent = obj.TablePanel.getPanel();
        end
        
        function setMenuNames(obj, menuNames)
            % SETMENUNAMES(MENUNAMES) adds a right-click menu to the table
            % for each string in MENUNAMES. A MenuSelectedEvent is
            % posted each time a menu is selected
            %
            % In order to add a seperator, use the constant MENU_SEPERATOR
            % in the list of MENUNAMES.
            %
            % MENUNAMES a cell array of menu strings
            
            assert(iscellstr(menuNames), 'menuNames must be a cell array of strings.');
            
            menuJList = java.util.ArrayList;
            
            for idx = 1 : length(menuNames)
                menuJList.add(menuNames{idx});
            end
            
            obj.TablePanel.setMenuNames(menuJList,...
                internal.ui.widget.TablePanelController.MENU_SEPARATOR,...
                internal.ui.widget.TablePanelController.CUT_COPY_PASTE);
        end
        
        function enableMenu(obj, menuNames, isEnabled)
            % ENABLEMENU(OBJ, MENUNAMES, ISENABLED) enable or disables
            % all the right-click menu items with name in MENUNAMES item
            % When a menu is disabled, it cannot be selected by the users.
            % If a right-click menu item is not present or a menuItem with
            % name in MENUNAMES does not exist this method returns without
            % any error.
            %
            % MENUNAMES cell array of menu item names that are being changed
            % ISENABLED true to enable the menu, false to disable the menu.
            
            assert(iscellstr(menuNames)...
                && islogical(isEnabled)...
                && length(menuNames) == length(isEnabled),...
                'menuName must be a cell array of strings. isEnabled must be logical');
            
            obj.TablePanel.enableMenus(menuNames, isEnabled);
        end
        
        function setTableData(obj, data, selectedRowIndex)
            % SETTABLEDATA(DATA, SELECTEDROWINDEX) displays DATA in the
            % table and selects row selectedRowIndex
            %
            % DATA the data to be displayed in the table. must be cell
            % array of strings or logicals.
            %
            % SELECTEDROWINDEX the row that should be selected
            
            assert(isscalar(selectedRowIndex) && isinteger(selectedRowIndex),...
                'Row Index must be scalar integer');
            
            if(isempty(data))
                obj.TablePanel.clearTableData;
                return;
            end
            
            javaList = obj.convertToJavaList(data);
            
            obj.TablePanel.setTableData(...
                javaList,...
                obj.getJavaIndex(selectedRowIndex));
        end
        
        function setColumnData(obj, columnIndex, data)
            % SETCOLUMNDATA(COLUMNINDEX, DATA) updates data in a column of
            % the table
            % DATA the data to be displayed in the table. must be 1 x N cell
            % array of strings or logicals.
            %
            % COLUMNINDEX the index of the column to update
            
            assert(iscellstr(data) ||...
                ( validateattributes(data, {'logical', 'cell'}, {'vector'}) &&...
                iscell(data)), 'tablepanel can only contain strings or logicals.');
            
            assert(isscalar(columnIndex) && isinteger(columnIndex),...
                'Column Index must be scalar integer');
            
            columnDataList = java.util.ArrayList;
            for j = 1 : length(data)
                columnDataList.add(data{j});
            end
            
            obj.TablePanel.setColumnData(obj.getJavaIndex(columnIndex),...
                columnDataList);
        end
        
        function setCellData(obj, rowIndex, columnIndex, data)
            % SETCELLDATA(COLUMNINDEX, DATA) updates data in a cell of
            % the table
            %
            % DATA the data to be displayed in the cell. must scalar string
            % or boolean
            %
            % ROWINDEX the row of the cell
            %
            % COLUMNINDEX the column of the cell
            
            assert((ischar(data) || islogical(data)),...
                'cell data must be a string or logical.');
            
            assert(isscalar(rowIndex) && isinteger(rowIndex),...
                'Row Index must be scalar integer');
            
            assert(isscalar(columnIndex) && isinteger(columnIndex),...
                'Column Index must be scalar integer');
            
            obj.TablePanel.setCellData(obj.getJavaIndex(rowIndex),...
                obj.getJavaIndex(columnIndex), data);
        end
        
        function setSelectedRow(obj, rowIndex)
            % SETSELECTEDROW(ROWINDEX) selectes a row in the table
            %
            %  ROWINDEX the row that should be selected
            
            assert(isscalar(rowIndex) && isinteger(rowIndex),...
                'Row Index must be scalar integer');
            
            obj.TablePanel.setSelectedRow(obj.getJavaIndex(rowIndex));
        end
        
        function setErrorMessage(obj, rowIndex, columnIndex, message)
            % SETERRORMESSAGE(ROWINDEX, COLUMNINDEX, MESSAGE) draws
            % red border around a cell and displays error message as a
            % tooltip in the selected cell.
            %
            % ROWINDEX the row of the cell
            %
            % COLUMNINDEX the column of the cell
            %
            % MESSAGE the tooltip of the cell
            
            assert(isscalar(rowIndex) && isinteger(rowIndex),...
                'Row Index must be scalar integer');
            
            assert(isscalar(columnIndex) && isinteger(columnIndex),...
                'Column Index must be scalar integer');
            
            assert(ischar(message), 'message must be a string');
            
            obj.TablePanel.setErrorMessage(obj.getJavaIndex(rowIndex),...
                obj.getJavaIndex(columnIndex),...
                message);
        end
        
        function setWarningMessage(obj, rowIndex, columnIndex, message)
            % SETWARNINGMESSAGE(ROWINDEX, COLUMNINDEX, MESSAGE) draws
            % yellow border around a cell and displays warning message as a
            % tooltip in the selected cell.
            %
            % ROWINDEX the row of the cell
            %
            % COLUMNINDEX the column of the cell
            %
            % MESSAGE the tooltip of the cell
            
            assert(isscalar(rowIndex) && isinteger(rowIndex),...
                'Row Index must be scalar integer');
            
            assert(isscalar(columnIndex) && isinteger(columnIndex),...
                'Column Index must be scalar integer');
            
            assert(ischar(message), 'message must be a string');
            
            obj.TablePanel.setWarningMessage(obj.getJavaIndex(rowIndex),...
                obj.getJavaIndex(columnIndex),...
                message);
        end
        
        function clearMessages(obj)
            % CLEARMESSAGES() clears all error or warning message from a
            % table.
            
            obj.TablePanel.clearMessages();
        end
        
        function setErrorBorderOnTable(obj)
            % SETERRORBORDERONTABLE() sets an error border on the table.
            
            obj.TablePanel.setErrorBorderOnTable();
        end
        
        function clearErrorBorderOnTable(obj)
            % CLEARERRORBORDERONTABLE() clears the error border on the table.
            
            obj.TablePanel.clearErrorBorderOnTable();
        end
        
        function hideTableHeaders(obj)
            % HIDETABLEHEADERS(OBJ) Hides the Table header
            
            obj.TablePanel.hideTableHeaders();
        end
        
        function editCell(obj, row, column)
           % EDITCELL(OBJ, ROW, COLUMN) puts the table cell in ROW and
           % COLUMN in edit mode so that user can start typing in it.
           % ROW index of the row of the cell
           % COLUMN index of the column of the cell
           
           obj.TablePanel.editCell(obj.getJavaIndex(row), obj.getJavaIndex(column)); 
        end
        
        function setPackColumns(obj,columnIndices)
            % SETPACKCOLUMNS - set which columns should pack. The width of the
            % column at the indices will have the preferred width as it's width
            % and the remaining columns will get the remaining space.
            %
            % The preferred width of a column is wide enough to show all of the
            % column header and the widest cell in the column
            %
            % COLUMNINDICES - array of column indices to pack
            
            assert(isnumeric(columnIndices),...
                'Column Indices must be numeric array');
            
            obj.TablePanel.setPackColumns(obj.getJavaIndex(columnIndices));
        end
        
        function addChildData(obj, rowIndex, childTableColumnNames, childTableData)
        % addChildData Set child table information in a hierarchical table.
        %
        %   This function is used for setting the information that to be
        %   used to build a child hierarchical nested table for a given
        %   row.
        %
        %   rowIndex - The row for which the child table will be built. 
        %   childTableColumnNames - The names of the columns on the child
        %       table as a cell array.
        %   childTableData - The data contained in the child table as an
        %       cell array.
        %
        
            % Pass the child table information to add to the table 
            % panel interface. Note the row index must be adjusted for 0
            % based indexing.
            obj.TablePanel.addChildData( ...
                rowIndex - 1, ...
                childTableColumnNames, ...
                childTableData);
        end
        
        function removeChildData(obj, rowIndex)
        % addChildData Set child table information in a hierarchical table.
        %
        %   This function is used for removing a child table from a row in
        %   a hierarchical nested table.
        %
        %   rowIndex - The row for which the child table will be removed. 
        %
        
            % Call to remove the child table from the specified row. Note
            % that the row index must be adjusted for 0 based indexing.
            obj.TablePanel.removeChildData(rowIndex - 1);
        end
        
        function removeAllChildren(obj)
        % removeAllChildren Clears all child tables in a hierarchical table.
        %
        %   This function is used to remove all child table information
        %   from the table.
        %
        
            % Clear the children.
            obj.TablePanel.removeAllChildren();
        end
        
    end
    %---------------------------------------------------------------------
    % Private functions
    methods(Access = 'private')
        
        function obj = handleRowSelected(obj, rowselectionevent)
            % HANDLEROWSELECTED(ROWSELECTIONEVENT) is invoked each time a
            % row is selected by a user in the table. converts the event
            % data to a MATLAB data
            %
            % ROWSELECTIONEVENT the java event data object.
            
            evtdata = struct('RowIndex', obj.getMIndex(rowselectionevent.getRowIndex));
            
            notify(obj, 'RowSelected', internal.event.WidgetEventData(evtdata));
        end
        
        function obj = handleCellEditedCallback(obj, celleditevent)
            % HANDLECELLEDITEDCALLBACK(CELLEDITEVENT) is invoked each time a
            % cell is edited by a user in the table. converts the event
            % data to a MATLAB data
            %
            % CELLEDITEVENT the java event data object.
            
            evtdata =struct('RowIndex', obj.getMIndex(celleditevent.getRowIndex),...
                'ColumnIndex', obj.getMIndex(celleditevent.getColumnIndex),...
                'OldValue', obj.getMData(celleditevent.getOldValue),...
                'NewValue', obj.getMData(celleditevent.getNewValue));
            
            notify(obj, 'CellEdited', internal.event.WidgetEventData(evtdata));
        end
        
        function obj = handleKeyPressed(obj, keypressedevt)
            % HANDLEKEYPRESSED(OBJ, KEYPRESSEDEVT) is invoked each time a
            % key is pressed by a user in the table. converts the event
            % data to a MATLAB data.
            %
            % KEYPRESSEDEVT the java event data object.
            
            evtdata =struct('RowIndex', obj.getMIndex(keypressedevt.getRowIndex),...
                'ColumnIndex', obj.getMIndex(keypressedevt.getColumnIndex),...
                'KeyChar', char(keypressedevt.getKeyChar),...
                'KeyText', char(keypressedevt.getKeyText),...
                'Modifiers', char(keypressedevt.getModifiers));
            
            if(strcmpi(evtdata.KeyText, 'Delete'))
                notify(obj, 'RowDeletionRequested', internal.event.WidgetEventData(evtdata));
            else
                notify(obj, 'KeyPressed', internal.event.WidgetEventData(evtdata));
            end
            
            
        end
        
        function obj = handleMenuSelected(obj, menuselectionevent)
            % HANDLEKEYPRESSED(OBJ, KEYPRESSEDEVT) is invoked each time a
            % menu item is selected by the user. converts the event
            % data to a MATLAB data.
            %
            % MENUSELECTIONEVENT the java event data object.
            
            evtdata =struct('RowIndex', obj.getMIndex(menuselectionevent.getRowIndex),...
                'ColumnIndex', obj.getMIndex(menuselectionevent.getColumnIndex),...
                'SelectedMenuName', char(menuselectionevent.getSelectedMenuName));
            
            notify(obj, 'MenuSelected', internal.event.WidgetEventData(evtdata));
        end
        
        function handleClipboardCallback(obj, clipboardevent)
            % HANDLECLIPBOARDCALLBACK(OBJ, CLIPBOARDEVENT) is invoked each
            % time cut,copy paste are selected from the right-click menu or
            % ctlr+c\x\v keys are pressed.
            %
            % CLIPBOARDEVENT the java event data object.
            
            evtdata =struct('RowIndex', obj.getMIndex(clipboardevent.getRowIndex),...
                'Type', char(clipboardevent.getType));
            
            notify(obj, 'ClipboardRequested', internal.event.WidgetEventData(evtdata));
        end
        
        function delete(obj)
            % DELETE Destroys the java object
            
            % the java object must be destroyed
            obj.TablePanel.destroy();
        end
    end
    %---------------------------------------------------------------------
    % Private static functions - Not Commented yet
    methods(Static, Access = 'private')
        
        function tableDataList = convertToJavaList(data)
            % TABLEDATALIST = CONVERTTOJAVALIST(DATA) stores the matlab
            % data in a java list
            %
            % DATA must be a m X n cell containing strings or logicals.
            % each column must contain data of the same type.
            
            datasize = size(data);            
            
            % assert that data is 2-d
            assert(length(datasize) == 2, 'Data must be a 2 dimensionsional cell array');
            
            % pre-allocate an array list to hold each column's data
            numberOfColumns = datasize(2);
            tableDataList = java.util.ArrayList(numberOfColumns);
            
            for idx = 1 : numberOfColumns
                
                % get data of a column
                columnData = data(:, idx);
                
                assert(iscellstr(columnData) ||...
                    (iscell(data) && all(cellfun(@islogical,columnData))),...
                    'tablepanel can only contain strings or logicals.');
                
                % Create an array list directly from the cell array of
                % data, and set it directly into the master ArrayList.
                %
                % Performance Note: This is much faster than incrementally
                % growing either the master ArrayList or the ArrayList
                % holding the data for a particular column
                
                % idx-1 for Java indexing
                tableDataList.add(idx-1, java.util.Arrays.asList(columnData));                                
            end
        end
        
        function mdata = getMData(javadata)
            % MDATA = GETMDATA(JAVADATA)converts java data to matlab data.
            % only supports strings objects
            %
            % JAVADATA - java object to convert
            %
            % MDATA - MATLAB data
            
            mdata = javadata;
            
            if(isa(javadata, 'java.lang.String') || isa(javadata, 'java.lang.Character'))
                mdata = char(javadata);
            end
            
            assert(~isjava(mdata),...
                'Failed to convert java data to MATLAB data. Unxepcted data');
        end
        
        function javaindex = getJavaIndex(mindex)
            % JAVAINDEX = GETJAVAINDEX(MINDEX) converts matlab 1-based
            % index to java 0-based index
            %
            % MINDEX - index in MATLAB
            %
            % JAVAINDEX - index in JAVA
            
            javaindex = mindex - 1;
        end
        
        function mindex = getMIndex(javaindex)
            % MINDEX = GETMINDEX(JAVAINDEX) converts java 0-based
            % index to MATLAB 1-based index
            %
            % JAVAINDEX - index in JAVA
            %
            % MINDEX - index in MATLAB
            mindex = javaindex + 1;
        end
    end
end

