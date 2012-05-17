function a = buildDialog(this)
%buildDialog Builds the import dialog

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/03/26 17:22:28 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.control.dialogs.*;
import com.mathworks.toolbox.control.tableclasses.*;

% Compensator data
% CompData=Editor.CompList;

if isempty(this.Parent)
    % Create Frame for import
    Frame = awtcreate('com.mathworks.mwswing.MJFrame','Ljava.lang.String;',...
        sprintf('System Data'));
else
     % Create Dialog for import
    Frame = awtcreate('com.mathworks.mwswing.MJDialog','Ljava.awt.Frame;Ljava.lang.String;Z',...
        this.Parent,sprintf('System Data'),true);
end
h = handle(Frame,'callbackproperties');
h.WindowClosingCallback = {@LocalDestroy this};

awtinvoke(Frame,'setName','MainFrame');
MainPanel=Frame.getContentPane;

% Panels
ImportPanel = MJPanel(BorderLayout(0, 10)); % Import Panel
title = BorderFactory.createTitledBorder(sprintf('Import Model'));
ImportPanel.setBorder(title);
Btnpanel = MJPanel(BorderLayout(0, 10)); % Button Panel

MainPanel.add(ImportPanel, BorderLayout.CENTER);
MainPanel.add(Btnpanel, BorderLayout.SOUTH);


% Create contents for buttons panel
BtnpanelRight = MJPanel(FlowLayout(FlowLayout.RIGHT));
BtnpanelLeft = MJPanel(FlowLayout(FlowLayout.LEFT));

% Make buttons and add to panel
Btn1 = MJButton(sprintf('OK'));
Btn1.setName('OK');
h = handle(Btn1, 'callbackproperties' ); 
h.ActionPerformedCallback = {@LocalOK this};

Btn2 = MJButton(sprintf('Cancel'));
Btn2.setName('Cancel');
h = handle(Btn2, 'callbackproperties' ); 
h.ActionPerformedCallback = {@LocalCancel this};

Btn3 = MJButton(sprintf('Help'));
Btn3.setName('Help');
h = handle(Btn3, 'callbackproperties' ); 
h.ActionPerformedCallback = {@LocalHelp this};

% Btn4 = MJButton(sprintf('Show Diagram'));
% Btn4.setName('Show Diagram')
% set(Btn4, 'ActionPerformedCallback', {@LocalShowDiagram})
% 
% Buttons = struct('Btn1', Btn1, 'Btn2', Btn2, 'Btn3', Btn3, 'Btn4', Btn4);

BtnpanelRight.add(Btn1);
BtnpanelRight.add(Btn2);
BtnpanelRight.add(Btn3);

%BtnpanelLeft.add(Btn4);


Btnpanel.add(BtnpanelRight, BorderLayout.EAST)
Btnpanel.add(BtnpanelLeft, BorderLayout.WEST)



% Contents for import panel
% Build Table
TableModel = ImportDialogTableModel();
Table = MJTable(TableModel);
Table.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
Scrollpane = MJScrollPane(Table);
awtinvoke(Table,'setPreferredScrollableViewportSize',Dimension(350, 150));
awtinvoke(Table.getTableHeader,'setReorderingAllowed(Z)',false); % Disable column reordering

ImportPanel.add(Scrollpane, BorderLayout.CENTER);

ImportBtnpanel = MJPanel(FlowLayout(FlowLayout.RIGHT));
BrowseBtn = MJButton(sprintf('Browse ...'));
BrowseBtn.setName('Browse')
h = handle(BrowseBtn, 'callbackproperties'); 
h.ActionPerformedCallback = {@LocalImportDialog this};
ImportBtnpanel.add(BrowseBtn);

ImportPanel.add(ImportBtnpanel, BorderLayout.SOUTH);

h = handle(TableModel, 'callbackproperties' ); 
TableListener = handle.listener(h,'tableChanged',{@LocalReadData this});

% Display and selection
% SelectPanel =  MJPanel(FlowLayout(FlowLayout.LEFT));
% Label1 = MJLabel(sprintf('Select Block: '));
% SelectPanel.add(Label1);
%SelectBox = MJComboBox(sprintf('Select Block:'));


%MainPanel.add(ImportPanel, BorderLayout.CENTER)

this.Handles = struct('TableModel',TableModel, ...
    'TableListener', TableListener, ...
    'Frame', Frame, ...
    'Button', BrowseBtn, ...
    'Table', Table);    
%     'TabbedPane', TabbedPane, ...
%     'Buttons', Buttons, ...
%     'TabHandles', TabHandles);

% listen for change in tab
%set(TabbedPane,'StateChangedCallback',{@LocalUpdateTarget Editor})

awtinvoke(Frame,'pack');

a = Frame;

%------------------------Callback Functions--------------------------------
% ------------------------------------------------------------------------%
% Function: LocalOK
% Purpose:  Export data and hide
% ------------------------------------------------------------------------%
function LocalOK(hSrc, event, this)
this.exportdata;
%awtinvoke(this.Handles.Frame,'setVisible(Z)',false);
Frame = this.Handles.Frame;
delete(this);
awtinvoke(Frame,'dispose');

% ------------------------------------------------------------------------%
% Function: LocalCancel
% Purpose:  Hide dialog Frame
% ------------------------------------------------------------------------%
function LocalCancel(hSrc, event, this)
%awtinvoke(this.Handles.Frame,'setVisible(Z)',false);
Frame = this.Handles.Frame;
delete(this);
awtinvoke(Frame,'dispose');

% ------------------------------------------------------------------------%
% Function: LocalHelp
% Purpose:  Help link
% ------------------------------------------------------------------------%
function LocalHelp(hSrc, event, this)
mapfile = ctrlguihelp;
helpview(mapfile,'sisoimportdialog','CSHelpWindow',this.Handles.Frame);

%-------------------------------------------------------------------------%
% Function: LocalImportDialog
% Abstract: Update target for selected compensator
%-------------------------------------------------------------------------%
function LocalImportDialog(eventsrc, eventdata, this)

% Open import dialog
dlg = sisogui.ImportDialogBrowser;
SelectedRows = awtinvoke(this.Handles.Table,'getSelectedRow()');
dlg.refresh(this, SelectedRows);
%centerfig(dlg.Frame,this.Handles.Frame);
awtinvoke(dlg.Frame,'setLocationRelativeTo',this.Handles.Frame);
dlg.show; 


%-------------------------------------------------------------------------%
% Function: LocalReadData
% Abstract: Read data entry from import table
%-------------------------------------------------------------------------%
function LocalReadData(eventsrc, eventdata, this)

% Reads and evaluate system data
ConfigData = this.Design;
% Evaluate in base
idx = eventdata.JavaEvent.getFirstRow;
expr =  this.Handles.TableModel.getValueAt(idx,1);
if ~isempty(expr)
   sys = evalin('base',expr,'[]');
else
   sys = [];
end
% Check that value is valid
if (isreal(sys) &&  isequal(size(sys),[1 1])) || (((isa(sys,'lti') || isa(sys,'idmodel'))) && isequal(iosize(sys),[1 1])) 
    if isa(sys,'double')
        sys = zpk(sys);
    end
   ConfigData.(this.ImportList{idx+1}).Value = sys;
   if isvarname(expr)
      ConfigData.(this.ImportList{idx+1}).Variable = expr;
   else
      ConfigData.(this.ImportList{idx+1}).Variable = '';
   end
else
    errstr = sprintf('Invalid value for %s',ConfigData.(this.ImportList{idx+1}).Name);
    awtinvoke('com.mathworks.mwswing.MJOptionPane', ...
        'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
        this.Handles.Frame, errstr, xlate('Import Warning'), com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
end 
this.Design = ConfigData;


function LocalDestroy(hsrc,event,this)
Frame = this.Handles.Frame;
delete(this);
awtinvoke(Frame,'dispose');


