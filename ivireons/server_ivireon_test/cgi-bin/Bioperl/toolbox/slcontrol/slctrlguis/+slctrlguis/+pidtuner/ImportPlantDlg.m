classdef ImportPlantDlg < handle
    % @ImportPlantDlg imports new LTI plant at specified operating point

    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.10.7.2.1 $ $Date: 2010/07/07 13:42:42 $
    
    properties
        Handles
        GCBH
        BackgroundColor
        SnapTime
    end

    properties (SetObservable = true)
        % set by linearization and listened by outside
        Plant
    end
    
    methods

        % Constructor
        function this = ImportPlantDlg(GCBH, BackgroundColor)
            this.GCBH = GCBH;
            this.BackgroundColor = BackgroundColor;
            this.SnapTime = 0;
            this.build;
        end
        
        % set visibility
        function setVisible(this, Visible, Parent)
            % get desired number of state from current op
            this.Handles.SnapshotTextField.setText(mat2str(this.SnapTime));
            if ishandle(this.GCBH)
                % initialize table
                this.refreshTable;
                % set visible on
                set(this.Handles.Figure,'Position',[0 0 100 22]);
                centerfig(this.Handles.Figure,Parent);
                set(this.Handles.Figure,'Visible',Visible);
            else
                str1 = pidtool.utPIDgetStrings('scd','tunerdlg_apply_error1');
                str2 = pidtool.utPIDgetStrings('scd','tunerdlg_apply_error2');
                str3 = pidtool.utPIDgetStrings('scd','tunerdlg_apply_error3');
                errordlg(sprintf('%s\n%s\n%s',str1,str2,str3),pidtool.utPIDgetStrings('cst','errordlgtitle'),'modal');    
            end
        end
    end
    
    methods (Access = protected)

        function build(this)
            
            %% create figure
            fig = figure('Color',this.BackgroundColor,...
                 'IntegerHandle','off', ...
                 'Menubar','None',...
                 'Toolbar','None',...
                 'DockControl','off',...
                 'Name',pidtool.utPIDgetStrings('scd','importplantdlg_title'), ...
                 'units','character',...
                 'NumberTitle','off', ...
                 'Visible','off', ...
                 'Tag','ImportPlantDlg',...
                 'WindowStyle','modal',...
                 'HandleVisibility','off');

            %% create main panel
            Prefs = cstprefs.tbxprefs;
            Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            titleborder = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',pidtool.utPIDgetStrings('scd','importplantdlg_border'));
            javaObjectEDT(titleborder);
            Panel.setBorder(titleborder),
            Panel.setLayout(java.awt.BorderLayout(0,15));
            Panel.setFont(Prefs.JavaFontB);            
            % row 1: current operating point
            CurrentRadioButton = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',pidtool.utPIDgetStrings('scd','importplantdlg_radio1'));
            CurrentRadioButton.setName('IMPORTPLANTDLG_CURRENTRADIOBUTTON');
            Panel.add(CurrentRadioButton,java.awt.BorderLayout.NORTH);
            % row 2: operating point in workspace
            Panel2 = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            Panel2.setLayout(java.awt.BorderLayout(0,0));
            ExistingRadioButton = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',pidtool.utPIDgetStrings('scd','importplantdlg_radio2'));
            ExistingRadioButton.setName('IMPORTPLANTDLG_EXISTINGRADIOBUTTON');
            Panel2.add(ExistingRadioButton,java.awt.BorderLayout.NORTH);
            Data = {blanks(10),blanks(10),blanks(10)};
            ColumnNames = {pidtool.utPIDgetStrings('scd','importplantdlg_colname1') ...
                pidtool.utPIDgetStrings('scd','importplantdlg_colname2') ...
                pidtool.utPIDgetStrings('scd','importplantdlg_colname3')};
            ExistingTableModel = javaObjectEDT('com.mathworks.toolbox.control.tableclasses.DiagramDisplayTableModel',Data,ColumnNames);
            ExistingTableModel.clearRows;
            EditableColumns = javaArray('java.lang.Boolean',3);
            EditableColumns(1) = java.lang.Boolean(false);
            EditableColumns(2) = java.lang.Boolean(false);
            EditableColumns(3) = java.lang.Boolean(false);
            ExistingTableModel.Editablecolumns = EditableColumns;
            ExistingTable = javaObjectEDT('com.mathworks.mwswing.MJTable',ExistingTableModel);
            ExistingTable.setName('IMPORTPLANTDLG_EXISTINGTABLE');
            ExistingTable.getTableHeader().setReorderingAllowed(false);
            ExistingTableScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',ExistingTable);
            Panel2.add(ExistingTableScrollPane,java.awt.BorderLayout.CENTER);
            listSelectionModel = javaObjectEDT('javax.swing.DefaultListSelectionModel');
            listSelectionModel.setSelectionMode(0);
            ExistingTable.setSelectionModel(listSelectionModel);
            Panel.add(Panel2,java.awt.BorderLayout.CENTER);
            % row 3: snapshot
            Panel3 = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            Panel3.setLayout(java.awt.BorderLayout(5,0));
            SnapshotRadioButton = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',pidtool.utPIDgetStrings('scd','importplantdlg_radio3'));
            SnapshotRadioButton.setName('IMPORTPLANTDLG_SNAPSHOTRADIOBUTTON');
            Panel3.add(SnapshotRadioButton,java.awt.BorderLayout.WEST);
            SnapshotTextField = javaObjectEDT('com.mathworks.mwswing.MJTextField',mat2str(this.SnapTime));
            SnapshotTextField.setName('IMPORTPLANTDLG_SNAPSHOTTEXTFIELD');
            Panel3.add(SnapshotTextField,java.awt.BorderLayout.CENTER);
            Panel.add(Panel3,java.awt.BorderLayout.SOUTH);
            [~, PanelCONTAINER] = javacomponent(Panel,[.1,.1,.9,.9],fig);
            set(PanelCONTAINER,'units','character')
            
            %% create button panel
            ButtonPanel = uipanel('parent',fig,'bordertype','none','units','character','BackgroundColor',this.BackgroundColor);
            % linearize
            LinearizeButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('scd','importplantdlg_btn1'));
            LinearizeButton.setName('IMPORTPLANTDLG_LINEARIZEBUTTON');
            [~, LinearizeButtonCONTAINER] = javacomponent(LinearizeButton,[.1,.1,.9,.9],ButtonPanel);
            set(LinearizeButtonCONTAINER,'units','character')
            % cancel
            CancelButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('scd','importplantdlg_btn2'));
            CancelButton.setName('IMPORTPLANTDLG_CANCELBUTTON');
            [~, CancelButtonCONTAINER] = javacomponent(CancelButton,[.1,.1,.9,.9],ButtonPanel);
            set(CancelButtonCONTAINER,'units','character')
            % help
            HelpButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_help'));
            HelpButton.setName('IMPORTPLANTDLG_HELPBUTTON');
            [~, HelpButtonCONTAINER] = javacomponent(HelpButton,[.1,.1,.9,.9],ButtonPanel);
            set(HelpButtonCONTAINER,'units','character')

            ButtonGroup = javaObjectEDT('javax.swing.ButtonGroup');
            ButtonGroup.add(CurrentRadioButton);
            ButtonGroup.add(ExistingRadioButton);
            ButtonGroup.add(SnapshotRadioButton);
            
            SnapshotRadioButton.setSelected(true);
            ExistingTable.setEnabled(false);
            
            this.Handles.Figure = fig;
            this.Handles.ButtonGroup = ButtonGroup;
            this.Handles.ButtonPanel = ButtonPanel;
            this.Handles.LinearizeButtonCONTAINER = LinearizeButtonCONTAINER;
            this.Handles.CancelButtonCONTAINER = CancelButtonCONTAINER;
            this.Handles.HelpButtonCONTAINER = HelpButtonCONTAINER;
            this.Handles.PanelCONTAINER = PanelCONTAINER;
            this.Handles.ExistingTable = ExistingTable;
            this.Handles.ExistingTableModel = ExistingTableModel;
            this.Handles.CurrentRadioButton = CurrentRadioButton;
            this.Handles.ExistingRadioButton = ExistingRadioButton;
            this.Handles.SnapshotRadioButton = SnapshotRadioButton;
            this.Handles.SnapshotTextField = SnapshotTextField;
            this.Handles.LinearizeButton = LinearizeButton;
            
            %% figure callbacks
            set(fig,...
                'ResizeFcn',@(x,y) layout(this),...
                'CloseRequestFcn',@(x,y) close(this));

            %% button callbacks
            h = handle(CurrentRadioButton,'callbackproperties');
            h.ActionPerformedCallback = {@CurrentRadioButtonCallback this};
            h = handle(ExistingRadioButton,'callbackproperties');
            h.ActionPerformedCallback = {@ExistingRadioButtonCallback this};
            h = handle(SnapshotRadioButton,'callbackproperties');
            h.ActionPerformedCallback = {@SnapshotRadioButtonCallback this};
            h = handle(SnapshotTextField,'callbackproperties');
            h.ActionPerformedCallback = {@SnapshotTextFieldCallback this};
            h = handle(LinearizeButton,'callbackproperties');
            h.ActionPerformedCallback = {@LinearizeButtonCallback this};
            h = handle(CancelButton,'callbackproperties');
            h.ActionPerformedCallback = {@CancelButtonCallback this};
            h = handle(HelpButton,'callbackproperties');
            h.ActionPerformedCallback = {@HelpButtonCallback this};
        end
        
        % obtain op at base workspace
        function refreshTable(this)
            Vars = evalin('base','whos');
            % find all 'opcond.OperatingPoint' objects
            Nvars = length(Vars);
            isValidType = false(Nvars,1);
            for ct=1:Nvars,
                isValidType(ct) = strcmp(Vars(ct).class,'opcond.OperatingPoint');
            end
            sysvar = {Vars(isValidType).name}.';
            % find all 'opcond.OperatingPoint' objects with correct model
            % name
            Nsys = length(sysvar);
            DataModels = cell(Nsys,1);
            % get variables from workspace
            for ct=1:Nsys
                DataModels(ct) = {evalin('base',sysvar{ct})};
            end
            isValidType = false(length(sysvar),1);
            for ct=1:length(sysvar)
                isValidType(ct) = (length(DataModels{ct})==1) && strcmp(DataModels{ct}.Model,get_param(bdroot(this.GCBH),'Name'));
            end
            ind = find(isValidType);
            VarNames = sysvar(ind);
            VarData = DataModels(ind);
            % find single siso LTI
            isValidType = false(Nvars,1);
            for ct=1:Nvars,
                isValidType(ct) = any(strcmp(Vars(ct).class,{'tf','zpk','ss','frd'})) ...
                    && evalin('base',['issiso(' Vars(ct).name ');']) ...
                    && prod(evalin('base',['size(' Vars(ct).name ');']))==1;            
            end
            sysvar = {Vars(isValidType).name}.';
            Nsys = length(sysvar);
            DataModels = cell(Nsys,1);
            % get variables from workspace
            for ct=1:Nsys
                DataModels(ct) = {evalin('base',sysvar{ct})};
            end
            VarNames = [VarNames;sysvar];
            VarData = [VarData;DataModels];
            % sysvar = sysvar(ind);
            if ~isempty(VarNames)
                % Get the data for the table
                data = createTableData(VarNames, VarData);
                % Update the table
                this.Handles.ExistingTableModel.setData(data);
            else
                % Clear the table
                this.Handles.ExistingTableModel.clearRows;
            end
        end
        
    end
    
end

% resize function
function layout(this)
    p = get(this.Handles.Figure,'Position');
    fw = p(3);  fh = p(4);
    set(this.Handles.ButtonPanel,'Position',[0, 0, fw, 3]);
    set(this.Handles.LinearizeButtonCONTAINER,'Position',[max(1,fw-51),0.5,15,2]);
    set(this.Handles.CancelButtonCONTAINER,'Position',[max(1,fw-34),0.5,15,2]);
    set(this.Handles.HelpButtonCONTAINER,'Position',[max(1,fw-17),0.5,15,2]);
    set(this.Handles.PanelCONTAINER,'Position',[2, 3, max(0.01,fw-4), max(0.01,fh-4)]);
end

% close function
function close(this)
    try %#ok<*TRYNC>
        set(this.Handles.Figure,'Visible','off');
    end
end

%% Callbacks
function CurrentRadioButtonCallback(hObject,eventdata,this) %#ok<*INUSD>
    this.Handles.ExistingTable.setEnabled(false);
    this.Handles.SnapshotTextField.setEnabled(false);
end

function ExistingRadioButtonCallback(hObject,eventdata,this) %#ok<*INUSD>
    this.Handles.ExistingTable.setEnabled(true);
    this.Handles.SnapshotTextField.setEnabled(false);
end

function SnapshotRadioButtonCallback(hObject,eventdata,this) %#ok<*INUSD>
    this.Handles.ExistingTable.setEnabled(false);
    this.Handles.SnapshotTextField.setEnabled(true);
end

function HelpButtonCallback(hObject,eventdata,this) %#ok<*INUSD>
    scdguihelp('pidtuner_importdlg_overview')
end

function CancelButtonCallback(hObject,eventdata,this) %#ok<*INUSL>
    close(this);
end

function SnapshotTextFieldCallback (hObject,eventdata,this) %#ok<*INUSD>
    newTime = str2double(this.Handles.SnapshotTextField.getText);
    if isnan(newTime) || ~isscalar(newTime) || ~isreal(newTime) || newTime<0 || ~isfinite(newTime)
        this.Handles.SnapshotTextField.setText(mat2str(this.SnapTime));
    else
        this.SnapTime = newTime;
    end
end

function LinearizeButtonCallback(hObject,eventdata,this)
    %% disable button
    this.Handles.LinearizeButton.setEnabled(false);
    %% remind user of the re-design risk
    btn1 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_continue');
    btn2 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_cancel');
    answer = questdlg(pidtool.utPIDgetStrings('scd','importplantdlg_warning'),...
        pidtool.utPIDgetStrings('scd','importplantdlg_title'),btn1,btn2,btn1);
    if strcmpi(answer,btn2)
        this.Handles.LinearizeButton.setEnabled(true);
        return
    end
    % check if there is any unapplied change in the block dialog
    if slctrlguis.pidtuner.utPIDhasUnappliedChanges(this.GCBH)
        errordlg(pidtool.utPIDgetStrings('scd','tunerdlg_unappliedchanges'),pidtool.utPIDgetStrings('cst','errordlgtitle'),'modal');
        this.Handles.LinearizeButton.setEnabled(true);
        return
    end
    %% start linearization
    wb = waitbar(0.5,pidtool.utPIDgetStrings('scd','tunerdlg_wb_str1'),...
        'Name',pidtool.utPIDgetStrings('scd','importplantdlg_title'));
    LinearizationSuccessful = true;
    if this.Handles.CurrentRadioButton.isSelected
        try
            G = slctrlguis.pidtuner.utPIDlinearize(this.GCBH, []);
        catch ME
            LinearizationSuccessful = false;
            handleLinearizationError(this,ME);
        end
    elseif this.Handles.ExistingRadioButton.isSelected
        row = this.Handles.ExistingTable.getSelectedRow;
        if row>=0
            varname = this.Handles.ExistingTable.getValueAt(row,0);
            op = evalin('base',varname);
            if isa(op,'lti')
                G = op;
            else
                try
                    G = slctrlguis.pidtuner.utPIDlinearize(this.GCBH, op);
                catch ME
                    LinearizationSuccessful = false;
                    handleLinearizationError(this,ME);
                end
            end
        else
            closewb(wb)
            errordlg(pidtool.utPIDgetStrings('scd','importplantdlg_operror1'),pidtool.utPIDgetStrings('cst','errordlgtitle'),'modal');
            return
        end
    elseif this.Handles.SnapshotRadioButton.isSelected
        SnapshotTextFieldCallback([],[],this);
        snaptime = this.SnapTime;
        try
            G = slctrlguis.pidtuner.utPIDlinearize(this.GCBH, snaptime);
            if ~isempty(G)
                G = G(end);
            end
        catch ME
            LinearizationSuccessful = false;
            handleLinearizationError(this,ME);
        end
    end
    this.Handles.LinearizeButton.setEnabled(true);
    closewb(wb)
    %% export G 
    if LinearizationSuccessful
        set(this.Handles.Figure,'Visible','off');
        this.Plant = G;
    end
end

function TableData = createTableData(VarNames,VarData)
    Nsys = length(VarData);
    TableData = javaArray('java.lang.Object',Nsys,3);

    for cnt=1:Nsys
        sys = VarData{cnt};
        TableData(cnt,1) = java.lang.String(VarNames{cnt});
        TableData(cnt,2) = java.lang.String(class(sys));
        if isa(sys,'lti')
            TableData(cnt,3) = java.lang.String(num2str(size(sys,'order')));
        else
            nStates = 0;
            for ct = 1:length(sys.States)
                nStates = nStates + sys.States(ct).Nx;
            end
            TableData(cnt,3) = java.lang.String(sprintf('%d - States',nStates));
        end
    end
end

function closewb(wb)
    if ishghandle(wb)
        delete(wb);
    end
end

function handleLinearizationError(this,ME)
    if strcmp(ME.identifier,'Slcontrol:pidtuner:tunerdlg_planterror')
        dlg = slctrlguis.pidtuner.InitialConditionDlg(this.Handles.Figure,this.BackgroundColor,'import');
        uiwait(dlg.Handles.Figure);
        delete(dlg);
    else
        if strcmp(ME.identifier,'MATLAB:MException:MultipleErrors')
            len = length(ME.cause);
            if len<=10
                errMessage = sprintf('%s\n',pidtool.utPIDgetStrings('scd','importplantdlg_summary1'));
            else
                len = 10;
                errMessage = sprintf('%s\n',pidtool.utPIDgetStrings('scd','importplantdlg_summary2'));
            end
            for ct = 1:len
                message = slprivate('removeHyperLinksFromMessage', ME.cause{ct}.message); 
                m1 = sprintf('\n--> %s\n', message);
                errMessage = [errMessage m1];
            end                        
        else
            errMessage = slprivate('removeHyperLinksFromMessage', ME.message); 
        end
        errordlg(errMessage,pidtool.utPIDgetStrings('cst','errordlgtitle'),'modal');
    end
end


