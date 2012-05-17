classdef BodeGain < editconstr.absEditor
    % BODEGAIN  Editor panel class for Bode gain constraint
    %
    
    % Author(s): A. Stothert 25-Nov-2008
    % Copyright 2008-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:47 $
    
    methods
        function this = BodeGain(SrcObj)
            this = this@editconstr.absEditor(SrcObj);
            this.Activated = true;
            this.setDisplayUnits('xunits','rad/sec');
            this.setDisplayUnits('yunits','dB');
            this.Orientation = 'horizontal';
        end
        
        function widgets = getWidgets(this,Container)
            %Import java packages
            import com.mathworks.toolbox.control.plotconstr.*;
            
            % Create widget
            columnNames    = javaArray('java.lang.String',6);
            columnNames(1) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorFrequency'));
            columnNames(2) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorMagnitude'));
            columnNames(3) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorFrequency'));
            columnNames(4) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorMagnitude'));
            columnNames(5) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorSlope'));
            columnNames(6) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorWeight'));
            btnLabels      = javaArray('java.lang.String',2);
            btnLabels(1)   = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorInsert'));
            btnLabels(2)   = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorDelete'));
            groupNames     = javaArray('java.lang.String',3);
            groupNames(1)  = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorStart'));
            groupNames(2)  = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorEnd'));
            groupNames(3)  = java.lang.String(sprintf(' '));
            hTable         = MultiEdgeHorizontalEditor(...
                columnNames,...
                groupNames, ...
                java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPWLEditorSegments')), ...
                btnLabels);
            
            %Add widget to container
            awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',hTable,java.awt.BorderLayout.CENTER);
            
            % Listeners: update table due to constraint data changes
            Listener = handle.listener(this.Data,'DataChanged',{@localUpdateTable this hTable});
            
            % Callbacks: update constraint data due to table changes
            tblView   = hTable.getTable;
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
                'Listeners', Listener, ...
                'tabOrder', tabOrder);
            
            % Initialize table data values
            localUpdateTable([],[],this,hTable,true);
        end
        function Slope = slope(this,iEdge)
            %SLOPE compute slope per decade for the Bode gain constraint
            
            if nargin < 2, iEdge = this.Data.SelectedEdge; end
            
            Freq = this.Data.getData('xdata');
            Mag  = this.Data.getData('ydata');
            
            dM = diff(Mag(iEdge,:),1,2);
            dF = diff(log10(Freq(iEdge,:)),1,2);
            dF(abs(dF)<eps) = nan;   %Avoid division by zero problems
            
            Slope = dM./dF;
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
    this.Data.SelectedEdge = iRow;
end

changeAccepted = false;  %Default reject any changes
if isscalar(newValue) && isreal(newValue) && ~isnan(newValue)
    switch iCol
        case {1,3}
            %Frequency changed
            changeAccepted = localEditFrequency(this,iCol,newValue);
        case {2, 4}
            %Magnitude changed
            changeAccepted = localEditMagnitude(this,iCol,newValue);
        case 5
            %Slope changed
            changeAccepted = localEditSlope(this,newValue);
        case 6
            %Weight changed
            changeAccepted = localEditWeight(this,newValue);
    end
end

if ~changeAccepted
    %Revert to old values
    localUpdateTable([],[],this,hTable);
end
end

%% Manage changes in the data object
function localUpdateTable(~,~,this,hTable,forced)

if nargin < 5, forced = false; end
if ~forced && ~hTable.isShowing
    %Quick return as not visible
    return
end

%Get segment data and convert to display units
xCoords = this.Data.getData('xdata');
xCoords = unitconv(xCoords,this.Data.getData('xUnits'), this.getDisplayUnits('xunits'));
yCoords = this.Data.getData('ydata');
yCoords = unitconv(yCoords,this.Data.getData('yUnits'), this.getDisplayUnits('yunits'));
OpenEnd = this.Data.getData('OpenEnd');
Weight  = this.Data.getData('weight');
iRow    = this.Data.SelectedEdge;
%Group data for display
nSegment = size(xCoords,1);  %Number of segments
Slope   = this.slope(1:nSegment);
newData = [...
    xCoords(:,1), ...
    yCoords(:,1), ...
    xCoords(:,2), ...
    yCoords(:,2), ...
    Slope, ...
    Weight];
if OpenEnd(1)
    newData(1,1) = -inf;
end
if OpenEnd(2)
    newData(end,3) = inf;
end

%Determine if the number of segments has changed
if ~isequal(nSegment, hTable.getTableModel.getRowCount) || ...
        ~isequal(numel(iRow),1)
    %Multiple segments or number of segments changed, update all of table
    hTable.setData(newData);
    awtinvoke(hTable.getTable,'revalidate()');
    awtinvoke(hTable.getTable,'repaint()');
else
    %Only one segment changed, update specific table rows
    hTable.setData(newData(iRow,:),iRow);
    if iRow > 1
        %Update previous segment
        hTable.setData(newData(iRow-1,:),iRow-1);
    end
    if iRow < nSegment
        %Update next segment
        hTable.setData(newData(iRow+1,:),iRow+1);
    end
    awtinvoke(hTable.getTable,'repaint()');
end

%Set frame done state to true, only used for testing
import com.mathworks.toolbox.control.util.*;
hFrame = ExplorerUtilities.getFrame(hTable);
if ~isempty(hFrame), hFrame.setDone(true); end
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

%% Manage changes in the frequency table column
function valueChanged = localEditFrequency(this,iCol,newValue)

% Update min or max frequency
if isequal(iCol,1)
    %Minimum value changed
    idxChange = 1;
else
    %Maximum value changed
    idxChange = 2;
end

iEdge   = this.Data.SelectedEdge;
iEdge   = iEdge(1);
xCoords = this.Data.getData('xdata');
yCoords = this.Data.getData('ydata');
OpenEnd = this.Data.getData('OpenEnd');
idxEnds = [1 size(xCoords,1)];
slope   = this.slope(iEdge);  % grab current slope before changes
if isnan(slope), slope = 0; end

%Convert displayed value into units of stored data
v = unitconv(newValue,this.getDisplayUnits('xunits'),this.Data.getData('xUnits'));

% Get new frequency range
FRange = xCoords(iEdge,:);
if ~isempty(v) && v>0
    if (idxChange==1 && v>=FRange(2))
        FRange(2) = v*FRange(2)/FRange(1);  % Adjust upper freq, preserving decade extent
    elseif (idxChange==2 && v<=FRange(1))
        FRange(1) = v*FRange(1)/FRange(2);
    end
    FRange(idxChange) = v;
    % Keep left of Nyquist freq
    if this.Ts,
        FRange = min([FRange ; (pi/this.Ts)*[0.9 1]]);
    end
    %Limit resize
    FRange(1) = this.limitResize(FRange(1),[],1);
    FRange(2) = this.limitResize(FRange(2),[],2);
end

% Update frequency data
valueChanged = false;
if isfinite(FRange(idxChange))
    %New coordinates are finite
    if OpenEnd(idxChange) && iEdge == idxEnds(idxChange)
        %Old coordinates were infinite
        valueChanged = true;
        %Create transaction to record changes
        T = this.recordon;
        %Modify edge values. Keep slope constant.
        newMag = yCoords(iEdge,1) + ...
            [0,slope*log10(FRange(2)/FRange(1))];
        xCoords(iEdge,:) = FRange;
        yCoords(iEdge,:) = newMag;
        this.Data.setData('xData',xCoords,'yData',yCoords);
        %Update open end setting
        OpenEnd(idxChange) = false;
        this.Data.setData('OpenEnd',OpenEnd);
        %Update neighbouring edges
        this.Data.updateCoords(this.Orientation)
        %Record the transaction
        this.recordoff(T);
    else
        %Old coordinates were finite
        if isequal(xCoords(iEdge,:),FRange)
            % Quick return since no change
            return
        else
            %Change value
            valueChanged = true;
            %Create transaction and make changes
            T = this.recordon;
            %Modify edge values
            newMag = yCoords(iEdge,1) + ...
                [0,slope*log10(FRange(2)/FRange(1))];
            xCoords(iEdge,:) = FRange;
            yCoords(iEdge,:) = newMag;
            this.Data.setData('xData',xCoords,'yData',yCoords);
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
        this.recordoff(T);
    end
end
end

%% Manage changes in the magnitude table column
function changeAccepted = localEditMagnitude(this,iCol,newValue)

% Update start or end magnitude
if isequal(iCol,2)
    %Start value changed
    idxChange = 1;
else
    %End value changed
    idxChange = 2;
end

vabs = unitconv(newValue,this.getDisplayUnits('yunits'),'abs');

changeAccepted = false;
if  ~isempty(newValue) && isfinite(newValue) && vabs>0,
    changeAccepted = true;
    v = unitconv(newValue,this.getDisplayUnits('yunits'),'dB');  % mag in dB
    iEdge = this.Data.SelectedEdge;
    iEdge = iEdge(1);
    % Round other mag to nearest feasible value
    jxc = 3-idxChange;  % complement
    xCoords = this.Data.getData('xdata');
    yCoords = this.Data.getData('ydata');
    df = log10(xCoords(iEdge,jxc)/xCoords(iEdge,idxChange));
    slope = (yCoords(iEdge,jxc)-v)/df;
    NewMag(1,[jxc idxChange]) = [v+slope*df,v];
    % Create transaction and update constraint data
    T = this.recordon;
    yCoords(iEdge,:) = unitconv(NewMag,'dB',this.Data.getData('yUnits'));
    this.Data.setData('ydata',yCoords);
    %Update neighbouring edges
    this.Data.updateCoords(this.Orientation)
    this.recordoff(T);
end
end

%% Manage changes in the slope table column
function changeAccepted = localEditSlope(this,newValue)

changeAccepted = false;
if ~isequal(newValue,this.slope)
    % Create transaction and update constraint data
    changeAccepted = true;
    iEdge    = this.Data.SelectedEdge;
    iEdge    = iEdge(1);
    xCoords  = this.Data.getData('xdata');
    yCoords  = this.Data.getData('ydata');
    df       = log10(xCoords(iEdge,2)/xCoords(iEdge,1));
    NewMagDB = unitconv(yCoords(iEdge,1),'dB',...
        this.Data.getData('yUnits')) + [0,newValue*df];
    T = this.recordon;
    yCoords(iEdge,:) = unitconv(NewMagDB,'dB',this.Data.getData('yUnits'));
    this.Data.setData('ydata',yCoords)
    %Update neighbouring edges
    this.Data.updateCoords(this.Orientation)
    this.recordoff(T);
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
        this.recordoff(T);
    end
end
end

%% Manage insert button actions
function localInsert(~,~,this,hTable)

iEdge = this.Data.SelectedEdge;
if isequal(numel(iEdge),1)
    %One edge selected split it
    this.Data.splitEdge(iEdge,{'log','linear'});
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
