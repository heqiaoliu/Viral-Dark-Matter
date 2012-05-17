function pnl = getDialogSchema(this) 
% GETDIALOGSCHEMA  Method to create DDG schema for time response
% requirement
%
 
% Author(s): A. Stothert 22-Jun-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:21 $

%% Container panel
pnl.Type    = 'panel';
pnl.Tag     = 'pnlTimeBound';
pnl.Name    = '';
pnl.RowSpan = [1 1];
pnl.ColSpan = [1 1];

%% Panel widgets

tblSegments.Type                 = 'table';
tblSegments.Grid                 = true;
tblSegments.Name                 = 'Segments:';
tblSegments.Editable             = true;
tblSegments.ValueChangedCallback = @localSegmentChanged;
tblSegments.HeaderVisibility     = [0 1];
tblSegments.RowHeader            = {''};
tblSegments.ColHeader            = {'Start time','Start magnitude','End time','End magnitude','Slope','Weight'};
tblSegments.RowSpan              = [1 1];
tblSegments.ColSpan              = [1 4];
%Get table data
xData            = this.getData('xData');
yData            = this.getData('yData');
nSegments        = size(xData,1);
tblSegments.Size = [nSegments,6];
data             = cell(nSegments,6);
for ct=1:nSegments
   data{ct,1} = mat2str(xData(ct,1));
   data{ct,2} = mat2str(yData(ct,1));
   data{ct,3} = mat2str(xData(ct,2));
   data{ct,4} = mat2str(yData(ct,2));
   data{ct,5} = mat2str(0);
   data{ct,6} = mat2str(1);
end
tblSegments.Data = data;

chkUpper.Type           = 'checkbox';
chkUpper.Tag            = 'chkUpper';
chkUpper.Name           = 'Lower bound';
chkUpper.Source         = this;
chkUpper.ObjectProperty = 'isLowerBound';
chkUpper.RowSpan        = [2 2];
chkUpper.ColSpan        = [1 1];

btnInsert.Type         = 'pushbutton';
btnInsert.Tag          = 'btnInsert';
btnInsert.Name         = 'Insert';
btnInsert.RowSpan      = [3 3];
btnInsert.ColSpan      = [3 3];
btnInsert.ObjectMethod = 'insertEdge';     %method on RequirementNode class

btnDelete.Type         = 'pushbutton';
btnDelete.Tag          = 'btnDelete';
btnDelete.Name         = 'Delete';
btnDelete.RowSpan      = [3 3];
btnDelete.ColSpan      = [4 4];
btnDelete.ObjectMethod = 'deleteEdge';     %method on RequirementNode class

%% Add widgets to panel
pnl.Items      = {tblSegments,chkUpper,btnInsert,btnDelete};
pnl.LayoutGrid = [3 4];
pnl.RowStretch = [1 0 0];
pnl.ColStretch = [1 0 0 0];

%% Manage segment table edits
function localSegmentChanged(dlg,iRow,iCol,newValue)

str = sprintf('Editing (%d,%d): %s',iRow+1,iCol+1,newValue);
disp(str);

