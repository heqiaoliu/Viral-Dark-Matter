function dlg = getDialogSchema(this,name) %#ok<INUSD>
%GETDIALOGSCHEMA metod to return dialog widgets
%

% Author(s): John Glass
% Revised:
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:19 $

% Determine if we are in expression mode or not
spec = this.Data.SCDBlockLinearizationSpecification;
isExpression = strcmp(spec.Type,'Expression');
isFormEnabled = strcmp(this.Data.SCDEnableBlockLinearizationSpecification,'on');
nrows = size(this.Data.PNPVTableData,1) > 0;

% Create Enable widget
enabCheckBox.Type = 'checkbox';
enabCheckBox.Tag  = 'enablereplacementCheckbox';
enabCheckBox.Name = ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:SpecifyTypeLabel');
enabCheckBox.ColSpan = [1 1];
enabCheckBox.RowSpan = [1 1];
enabCheckBox.ObjectMethod = 'enableSpecChange';
enabCheckBox.MethodArgs = {'%dialog', '%value'};
enabCheckBox.ArgDataTypes = {'handle', 'mxArray'};

% Create specification type combobox
methodComboBox.Type = 'combobox';
methodComboBox.Tag  = 'methodComboBox';
methodComboBox.Name = '';
methodComboBox.Enabled = isFormEnabled;
methodComboBox.ColSpan = [2 2];
methodComboBox.RowSpan = [1 1];
methodComboBox.Entries = {ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:MATLABExpression'),...
                            ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:ConfigurationFunction')};
methodComboBox.Values = [1 2];
methodComboBox.ObjectMethod = 'methodChange';
methodComboBox.MethodArgs = {'%dialog', '%value'};
methodComboBox.ArgDataTypes = {'handle', 'mxArray'};

% Create the instruction string
instrText.Type = 'text';
instrText.Tag  = 'instructionText';
if isExpression
    instrText.Name = ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:ExpressionInstruction');
else
    instrText.Name = ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:FunctionInstruction');
end
instrText.Enabled = isFormEnabled;
instrText.ColSpan = [1 2];
instrText.RowSpan = [2 2];
instrText.Visible = true;
instrText.WordWrap = true;

% Create the specification edit field
specificationEdit.Type = 'edit';
specificationEdit.Tag = 'specificationEdit';
specificationEdit.Enabled = isFormEnabled;
specificationEdit.ColSpan = [1 2];
specificationEdit.RowSpan = [3 3];
specificationEdit.ObjectMethod = 'specificationChange';
specificationEdit.MethodArgs = {'%dialog', '%value'};
specificationEdit.ArgDataTypes = {'handle', 'mxArray'};

% Create the table widget
paramTable.Type = 'table';
paramTable.Tag = 'paramTable';
paramTable.Enabled = isFormEnabled;
paramTable.Grid = true;
paramTable.ColSpan = [1 1];
paramTable.RowSpan = [1 1];
paramTable.Editable = true;
paramTable.RowHeader = {''};
paramTable.ColHeader = {ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:ParameterNameHeader'),...
                        ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:ParameterValueHeader')};
paramTable.ColumnCharacterWidth = [numel(paramTable.ColHeader{1}),numel(paramTable.ColHeader{2})];
paramTable.HeaderVisibility     = [0 1];
paramTable.ValueChangedCallback = @paramTableValueChangedCB;
paramTable.CurrentItemChangedCallback = @paramTableFocusChangedCB;
paramTable.Visible = ~isExpression;
paramTable.Data = this.Data.PNPVTableData;
paramTable.SelectedRow = this.Data.TableRowFocus-1;

% Create the table modification buttons
iconPath = fullfile(matlabroot,'toolbox','slcontrol','slctrlutil','resources');
btnAddRow.Type          = 'pushbutton';
btnAddRow.Tag           = 'btnAddRow';
btnAddRow.FilePath      = fullfile(iconPath, 'insert_row.png'); 
btnAddRow.Enabled = isFormEnabled;
btnAddRow.RowSpan       = [1 1];
btnAddRow.ColSpan       = [1 1];
btnAddRow.Source = this;
btnAddRow.ObjectMethod = 'addRow';
btnAddRow.MethodArgs = {'%dialog'};
btnAddRow.ArgDataTypes = {'handle'};

btnRemRow.Type          = 'pushbutton';
btnRemRow.Tag           = 'btnRemRow';
btnRemRow.FilePath      = fullfile(iconPath, 'delete.png');
btnRemRow.Enabled = isFormEnabled && nrows;
btnRemRow.RowSpan       = [2 2];
btnRemRow.ColSpan       = [1 1];
btnRemRow.Source = this;
btnRemRow.ObjectMethod = 'remRow';
btnRemRow.MethodArgs = {'%dialog'};
btnRemRow.ArgDataTypes = {'handle'};

btnMoveRowUp.Type          = 'pushbutton';
btnMoveRowUp.Tag           = 'btnMoveRowUp';
btnMoveRowUp.FilePath      = fullfile(iconPath, 'arrow_move_up_lg.png');
btnMoveRowUp.Enabled = isFormEnabled && nrows;
btnMoveRowUp.RowSpan       = [3 3];
btnMoveRowUp.ColSpan       = [1 1];
btnMoveRowUp.Source = this;
btnMoveRowUp.ObjectMethod = 'moveRowUp';
btnMoveRowUp.MethodArgs = {'%dialog'};
btnMoveRowUp.ArgDataTypes = {'handle'};

btnMoveRowDown.Type          = 'pushbutton';
btnMoveRowDown.Tag           = 'btnMoveRowDown';
btnMoveRowDown.FilePath      = fullfile(iconPath, 'arrow_move_down_lg.png');
btnMoveRowDown.Enabled = isFormEnabled && nrows;
btnMoveRowDown.RowSpan       = [4 4];
btnMoveRowDown.ColSpan       = [1 1];
btnMoveRowDown.Source = this;
btnMoveRowDown.ObjectMethod = 'moveRowDown';
btnMoveRowDown.MethodArgs = {'%dialog'};
btnMoveRowDown.ArgDataTypes = {'handle'};
  
% Set the data for the Dialog
enabCheckBox.Value  = isFormEnabled;
if isExpression
    methodComboBox.Value = 0;
else
    methodComboBox.Value = 1;
end
specificationEdit.Value = spec.Specification;

paramTable.Data = this.Data.PNPVTableData;
paramTable.Size = size(paramTable.Data);

% Create the containing panels
spacer.Type = 'panel';
spacer.RowSpan = [5 5];
spacer.ColSpan = [1 1];

sub_butnBar.Type = 'panel';
sub_butnBar.LayoutGrid = [5 1];
sub_butnBar.Items = {btnAddRow, btnRemRow, btnMoveRowUp, btnMoveRowDown, spacer};
sub_butnBar.RowSpan = [1 1];
sub_butnBar.ColSpan = [2 2];
sub_butnBar.ColStretch = 0;
sub_butnBar.RowStretch = [0 0 0 0 1];
sub_butnBar.Visible = ~isExpression;

tablePanel.Type = 'panel';
tablePanel.LayoutGrid = [1 2];
tablePanel.Items = {paramTable, sub_butnBar};
tablePanel.RowSpan = [5 5];
tablePanel.ColSpan = [1 2];
tablePanel.ColStretch = [1 0];
tablePanel.RowStretch = 1;
tablePanel.Visible = ~isExpression;
% tablePanel.isScrollable = true;

% Main dialog
dlg.DialogTitle = ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:DialogTitle',get_param(this.Block,'Name'));
dlg.HelpMethod  = 'scdguihelp';
dlg.HelpArgs    = {'blocklinspecdlg'};
dlg.Items       = {enabCheckBox,methodComboBox,...
                    instrText,specificationEdit,tablePanel};
dlg.LayoutGrid  = [5 2];
dlg.RowStretch  = [0 0 0 0 1];
dlg.ColStretch  = [0 1];
dlg.PostApplyCallback = 'postApplyCallback';
dlg.PostApplyArgs = {this};
dlg.PostApplyArgsDT = {'MATLAB array'};
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function paramTableValueChangedCB(dlg,row,col,value)
this = dlg.getDialogSource();
if col == 0 && ~isempty(value) && ~isvarname(value)
    errordlg(ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:InvalidParameterName',value),'Simulink Control Design')
    return
end
this.Data.PNPVTableData{row+1,col+1} = value;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function paramTableFocusChangedCB(dlg,row,col) %#ok<INUSD>
this = dlg.getDialogSource();
this.Data.TableRowFocus = row + 1;
end
