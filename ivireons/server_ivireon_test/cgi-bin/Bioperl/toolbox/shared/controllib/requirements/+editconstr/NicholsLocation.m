classdef NicholsLocation < editconstr.absEditor
    % NICHOLSLOCATION  Editor panel class for Nichols location constraint
    %
    
    % Author(s): A. Stothert 05-Jan-2009
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:51 $
    
    methods
        function this = NicholsLocation(SrcObj)
            this = this@editconstr.absEditor(SrcObj);
            this.Activated = true;
            this.setDisplayUnits('xunits','deg');
            this.setDisplayUnits('yunits','dB');
            this.Orientation = 'both';
        end
        
        function widgets = getWidgets(this,Container)
            %Import java packages
            import com.mathworks.toolbox.control.plotconstr.*;
            
            % Create widget
            columnNames    = javaArray('java.lang.String',3);
            columnNames(1) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorOpenLoopPhase'));
            columnNames(2) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorOpenLoopGain'));
            columnNames(3) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorWeight'));
            btnLabels      = javaArray('java.lang.String',2);
            btnLabels(1)   = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorInsert'));
            btnLabels(2)   = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorDelete'));
            hTable         = MultiEdgeFreeFormEditor(...
                columnNames,...
                java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorVertices')), ...
                btnLabels);
            
            %Add widget to container
            awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',hTable,java.awt.BorderLayout.CENTER);
            
            % Listeners: update table due to constraint data changes
            Listener = handle.listener(this.Data,'DataChanged',{@localUpdateTable this hTable});
            
            % Callbacks: update constraint data due to table changes
            tblView = hTable.getTable;
            h = handle(tblView,'callbackproperties');
            L = handle.listener(h,'PropertyChange', {@localChangeEdge this});
            Listener = [Listener; L];
            tblData = hTable.getTableModel;
            h = handle(tblData,'callbackproperties');
            L = handle.listener(h,'TableChanged', {@localDataChanged this hTable});
            Listener = [Listener; L];
            btnInsert = hTable.getInsertBtn;
            h = handle(btnInsert,'callbackproperties');
            L = handle.listener(h,'ActionPerformed', {@localInsert this hTable});
            Listener = [Listener; L];
            btnDelete = hTable.getDeleteBtn;
            h = handle(btnDelete,'callbackproperties');
            L = handle.listener(h,'ActionPerformed', {@localDelete this hTable});
            Listener = [Listener; L];
            
            %Store tab order
            tabOrder    = javaArray('java.awt.Component',2);
            tabOrder(1) = btnInsert;
            tabOrder(2) = btnDelete;
            
            % Save other handles
            widgets = struct(...
                'Panels', hTable, ...
                'Handles', hTable, ...
                'Listeners',Listener, ...
                'tabOrder', tabOrder);
            
            % Initialize table data values
            localUpdateTable([],[],this,hTable,true);
        end
    end
end

%% Manage table data change actions
function localDataChanged(~,eventData,this,hTable)

%Find out what changed and the new value
iRow     = eventData.JavaEvent.getFirstRow + 1;    %Java offset, single row selection
iCol     = eventData.JavaEvent.getColumn + 1;
newValue = hTable.getData(iRow,iCol);
newValue = ctrluis.convertJavaComplexToDouble(newValue);

%Make sure only one edge is selected
iEdge = this.Data.SelectedEdge;
if numel(iEdge) > 1 || iEdge ~= iRow
    nEdge = size(this.Data.getData('xdata'),1);
    this.Data.SelectedEdge = min(iRow,nEdge);
end

changeAccepted = false;  %Default reject any changes
if isscalar(newValue) && isreal(newValue) && ~isnan(newValue)
    switch iCol
        case {1,2}
            %Phase/Gain changed
            changeAccepted = localEditCoord(this,iCol,iRow,newValue);
        case 3
            %Weight changed
            changeAccepted = localEditWeight(this,newValue);
    end
end

if ~changeAccepted
    %Revert to old values
    localUpdateTable([],[],this,hTable);
end
end

%% Manage changes in the plotconstr object
function localUpdateTable(~,~,this,hTable,forced)

if nargin < 5, forced = false; end
if ~forced && ~hTable.isShowing
    %Quick return as not visible
    return
end

%Get segment data and convert to display units
xCoords = unitconv(this.Data.getData('xdata'),this.Data.getData('xUnits'),this.getDisplayUnits('xunits'));
yCoords = unitconv(this.Data.getData('ydata'),this.Data.getData('yUnits'),this.getDisplayUnits('yunits'));
Weight  = this.Data.getData('weight');
%Group data for display
nVertices = size(xCoords,1) + 1;  %Number of vertices = segments + 1
newData = [...
    [xCoords(:,1); xCoords(end,2)], ...
    [yCoords(:,1); yCoords(end,2)], ...
    [Weight; Weight(end)]];

%Determine if the number of segments has changed
iRow = this.Data.SelectedEdge;
if ~isequal(nVertices, hTable.getTableModel.getRowCount) || ...
        ~isequal(numel(iRow),1)
    %Multiple segments or number of segments changed, update all of table
    hTable.setData(newData);
    awtinvoke(hTable.getTable,'revalidate()');
    awtinvoke(hTable.getTable,'repaint()');
else
    %Only one vertex changed, update specific table rows
    hTable.setData(newData(iRow,:),iRow);
    if iRow > 1
        %Update previous vertex
        hTable.setData(newData(iRow-1,:),iRow-1);
    end
    if iRow < nVertices
        %Update next vertex
        hTable.setData(newData(iRow+1,:),iRow+1);
    end
    awtinvoke(hTable.getTable,'repaint()');
end

%Set frame done state to true, only used for testing
import com.mathworks.toolbox.control.util.*;
hFrame = ExplorerUtilities.getFrame(hTable);
if ~isempty(hFrame), hFrame.setDone(true); end
end

%% Manage changes in the phase/gain table columns
function valueChanged = localEditCoord(this,iCol,iRow,newValue)

%Find axes units
if isequal(iCol,1)
    WhichUnits = 'xunits';
    WhichCoord = 'xdata';
else
    WhichUnits = 'yunits';
    WhichCoord = 'ydata';
end

Coords  = this.Data.getData(WhichCoord);
iEdge   = this.Data.SelectedEdge;
iEdge   = iEdge(1);
OpenEnd = this.Data.getData('OpenEnd');
idxEnds = [1 size(Coords,1)];
v       = unitconv(newValue,this.getDisplayUnits(WhichUnits),this.Data.getData(WhichUnits));

%Find which element to change
if iRow <= size(Coords,1)
    %Dealing with all but last vertex
    idxChange = 1;
else
    %Dealing with last vertex
    idxChange = 2;
end

% Get new range
Range = Coords(iEdge,:);
Range(idxChange) = v;
valueChanged = false;
if isfinite(Range(idxChange))
    %New coordinates are finite
    if OpenEnd(idxChange) && iEdge == idxEnds(idxChange)
        %Old coordinates were infinite
        valueChanged = true;
        %Create transaction and make changes
        T = this.recordon;
        Coords(iEdge,:) = Range;
        this.Data.setData(WhichCoord,Coords);
        %Update open end setting
        OpenEnd(idxChange) = false;
        this.Data.setData('OpenEnd',OpenEnd);
        %Update neighbouring edges
        this.Data.updateCoords(this.Orientation)
        %Record the transaction
        this.recordoff(T);
    else
        %Old coordinates were finite
        if isequal(Coords(iEdge,:),Range)
            %Quick return since no change
            return
        else
            %Change value
            valueChanged = true;
            %Create transaction and make changes
            T = this.recordon;
            Coords(iEdge,:) = Range;
            this.Data.setData(WhichCoord,Coords);
            %Update neighbouring edges
            this.Data.updateCoords(this.Orientation)
            %Record the transaction
            this.recordoff(T);
        end
    end
else
    %New coordinates are infinite
    if iEdge == idxEnds(idxChange) && ~OpenEnd(idxChange)
        %Update open end setting
        valueChanged = true;
        %Create transaction and make changes
        T = this.recordon;
        OpenEnd(idxChange) = true;
        this.Data.setData('OpenEnd',OpenEnd);
        %Record the transaction
        this.recordoff(T);
    end
end
end

%% Manage changes in the weight table column
function changeAccepted = localEditWeight(this,newValue)

changeAccepted = false;
if newValue >=0 && newValue <=1
    Weight = this.Data.getData('weight');
    iEdge  = this.Data.SelectedEdge;
    iEdge  = iEdge(1);
    if ~isequal(Weight(iEdge),newValue)
        % Create transaction and update constraint data
        changeAccepted = true;
        Weight(iEdge) = newValue;
        T = this.recordon;
        this.Data.setData('weight',Weight);
        %Record the transaction
        this.recordoff(T);
    end
end
end

%% Manage changes in selected edge
function localChangeEdge(~,eventData,this)

NewEdge = eventData.Source.getSelectedRows+1;
if isequal(numel(NewEdge),1)
    SelectedEdge = this.Data.SelectedEdge;
    nEdge = size(this.Data.getData('xdata'),1);
    if ~isequal(NewEdge,SelectedEdge(1)) && ...
            (NewEdge > 0) && ...
            (NewEdge <= nEdge)
        this.Data.SelectedEdge = NewEdge;
    end
end
end

%% Manage insert button actions
function localInsert(~,~,this,hTable)

iEdge = this.Data.SelectedEdge;
if isequal(numel(iEdge),1)
    %One edge selected split it
    this.Data.splitEdge(iEdge);
    if ~this.Activated
        %Splitting during creation, force table update
        localUpdateTable([],[],this,hTable)
    end
end
end

%% Manage delete button actions
function localDelete(~,~,this,hTable)

iEdge = this.Data.SelectedEdge;
nEdge = size(this.Data.getData('xdata'),1);
if numel(iEdge) < nEdge
    %Delete edges but not all edges
    for ct = 1:numel(iEdge)
        this.Data.removeEdge(iEdge(ct),this.Orientation)
    end
    if ~this.Activated
        %Deleting during creation, force table update
        localUpdateTable([],[],this,hTable);
    end
else
    %Delete the whole constraint
    if this.Activated
        %Remove all edges, this deletes the data object
        this.Data.removeEdge(1:nEdge)
    else
        errStr = ctrlMsgUtils.message('Controllib:graphicalrequirements:errDeleteLastEdgeOfNew');
        com.mathworks.mwswing.MJOptionPane.showMessageDialog(hTable,errStr,...
            ctrlMsgUtils.message('Controllib:graphicalrequirements:errDesignRequirement'),...
            com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
    end
end
end
