function dlgstruct = modelddg(h,name)
% MODELDDG Dynamic dialog for Simulink BlockDiagram objects.

% To lauch this dialog in MATLAB, use:
%    >> a = Simulink.BlockDiagram;
%    >> DAStudio.Dialog(a);

% Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.6.21 $

  %------------------------------------------------------------------------
  % Tab One contains:
  % - TextBrowser widget with model info
  %------------------------------------------------------------------------
  info.Type = 'textbrowser';
  info.Text = model_info_l(h);
  info.DialogRefresh = 1;
  info.Tag = 'Info';
  
  %------------------------------------------------------------------------
  % Tab Two contains:
  % - Model callback functions widgets
  %------------------------------------------------------------------------
  
  callbackProp   = {'PreLoadFcn'  ,...
                    'PostLoadFcn' ,...
                    'InitFcn'     ,...
                    'StartFcn'    ,...
                    'PauseFcn'    ,...
                    'ContinueFcn'    ,...
                    'StopFcn'     ,...
                    'PreSaveFcn'  ,...
                    'PostSaveFcn' ,...
                    'CloseFcn'};
  
  callbackPrompt = {DAStudio.message('Simulink:dialog:ModelCallbackPromptPreLoadFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptPostLoadFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptInitFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptStartFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptPauseFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptContinueFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptStopFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptPreSaveFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptPostSaveFcn'),...
                    DAStudio.message('Simulink:dialog:ModelCallbackPromptCloseFcn')};
               
  widget_tags =     {'Model pre-load function:',...
                    'Model post-load function:',...
                    'Model initialization function:',...
                    'Simulation start function:',...
                    'Simulation pause function:',...
                    'Simulation continue function:',...
                    'Simulation stop function:',...
                    'Model pre-save function:',...
                    'Model post-save function:',...
                    'Model close function:'};
  
  items       = cell(1, length(callbackProp));
  markedProps = callbackProp;
  for i = 1:length(callbackProp)
      widget.Name           = callbackPrompt{i};
      widget.Type           = 'editarea';
      widget.ObjectProperty = callbackProp{i};
      widget.Tag            = widget_tags{i};

      panel.Type            = 'panel';
      panel.Items           = {widget};
      panel.Tag		    = strcat('Panel_', num2str(i));

      items(i) = {panel};
      
      if ~isempty(h.(callbackProp{i}))
          markedProps{i} = [markedProps{i} '*'];
      end
  end
  
  cbTree.Name         = DAStudio.message('Simulink:dialog:ModelCbTreeName');
  cbTree.Type         = 'tree';
  cbTree.RowSpan      = [1 1];
  cbTree.ColSpan      = [1 1];
  cbTree.TreeItems    = markedProps;
  cbTree.TreeItemIds  = num2cell(0:length(cbTree.TreeItems)-1);
  cbTree.TargetWidget = 'CallbackStack';
  cbTree.Graphical    = true;
  cbTree.MinimumSize  = [85 10];
  cbTree.Tag          = 'CallbackFunctions';
  
  cbStack.Type    = 'widgetstack';
  cbStack.RowSpan = [1 1];
  cbStack.ColSpan = [2 2];
  cbStack.Tag     = 'CallbackStack';
  cbStack.Items   = items;
    
  %------------------------------------------------------------------------
  % Tab Three contains:
  % - Model information (version, created by etc) and model history widgets
  %------------------------------------------------------------------------  
  
  readOnly.Name = DAStudio.message('Simulink:dialog:ModelReadOnlyName');
  readOnly.Tag = readOnly.Name;
  readOnly.RowSpan = [3 3];
  readOnly.ColSpan = [1 1];
  readOnly.Type = 'checkbox';
  readOnly.DialogRefresh = 1;
  readOnly.MatlabMethod = 'modelddg_readOnly_cb';
  readOnly.MatlabArgs = {h, '%dialog', '%value'};
  if (strcmp(h.EditVersionInfo,'ViewCurrentValues'))
    readOnly.Value = 1;
    editMode = 0;
  else
    readOnly.Value = 0;
    editMode = 1;
  end
  
  creatorEditLbl.Name = DAStudio.message('Simulink:dialog:ModelCreatorEditLblName');
  creatorEditLbl.Type = 'text';
  creatorEditLbl.RowSpan = [1 1];
  creatorEditLbl.ColSpan = [1 1];
  creatorEditLbl.Tag = 'CreatorEditLbl';
  
  creatorEdit.Name = '';
  creatorEdit.Tag = creatorEditLbl.Name;
  creatorEdit.RowSpan = [1 1];
  creatorEdit.ColSpan = [2 2];
  creatorEdit.Type = 'edit';
  creatorEdit.ObjectProperty = 'Creator';
  if editMode == 1
      creatorEdit.Enabled = 1;
  else
      creatorEdit.Enabled = 0;
  end
 
  lastByValLbl.Name = DAStudio.message('Simulink:dialog:ModelLastByValLblName');
  lastByValLbl.Type = 'text';
  lastByValLbl.RowSpan = [1 1];
  lastByValLbl.ColSpan = [3 3];
  lastByValLbl.Tag = 'LastByValLbl';
  
  lastByVal.Name = '';
  lastByVal.Tag = lastByValLbl.Name;
  lastByVal.RowSpan = [1 1];
  lastByVal.ColSpan = [4 4];
  lastByVal.Type = 'edit';
  if (editMode == 1)
    lastByVal.ObjectProperty = 'ModifiedByFormat';
  else
    lastByVal.Value = h.LastModifiedBy;
    lastByVal.Enabled = 0;
  end

  %Created By Edit area
  createdEditLbl.Name = DAStudio.message('Simulink:dialog:ModelCreatedEditLblName');
  createdEditLbl.Type = 'text';
  createdEditLbl.RowSpan = [2 2];
  createdEditLbl.ColSpan = [1 1];
  createdEditLbl.Tag = 'CreatedEditLbl';
  
  createdEdit.Name = '';
  createdEdit.Tag = createdEditLbl.Name;
  createdEdit.RowSpan = [2 2];
  createdEdit.ColSpan = [2 2];
  createdEdit.Type = 'edit';
  createdEdit.ObjectProperty = 'Created';
  if editMode == 1
      createdEdit.Enabled = 1;
  else
      createdEdit.Enabled = 0;
  end
 
  lastOnVerValLbl.Name = DAStudio.message('Simulink:dialog:ModelLastOnVerValLblName'); 
  lastOnVerValLbl.Type = 'text';
  lastOnVerValLbl.RowSpan = [2 2];
  lastOnVerValLbl.ColSpan = [3 3];
  lastOnVerValLbl.Tag = 'LastOnVerValLbl';
  
  lastOnVerVal.Name = '';
  lastOnVerVal.Tag = lastOnVerValLbl.Name;
  lastOnVerVal.RowSpan = [2 2];
  lastOnVerVal.ColSpan = [4 4];
  lastOnVerVal.Type = 'edit';
  lastOnVerVal.Value = h.LastModifiedDate;
  if (editMode == 1)
    lastOnVerVal.ObjectProperty = 'ModifiedDateFormat';
  else
    lastOnVerVal.Value = h.LastModifiedDate;
    lastOnVerVal.Enabled = 0;
  end
  
  modelVerValLbl.Name = DAStudio.message('Simulink:dialog:ModelModelVerValLblName');
  modelVerValLbl.Type = 'text';
  modelVerValLbl.RowSpan = [3 3];
  modelVerValLbl.ColSpan = [3 3];
  modelVerValLbl.Tag = 'ModelVerValLbl';
  
  modelVerVal.Name = '';
  modelVerVal.Tag = modelVerValLbl.Name;
  modelVerVal.RowSpan = [3 3];
  modelVerVal.ColSpan = [4 4];
  modelVerVal.Type = 'edit';
  if (editMode == 1)
    modelVerVal.ObjectProperty = 'ModelVersionFormat';
  else
    modelVerVal.Enabled = 0;
    modelVerVal.Value = h.ModelVersion;
  end
  
  version.Name = DAStudio.message('Simulink:dialog:ModelVersionName');
  version.Type = 'group';
  version.LayoutGrid = [3 4];
  version.ColStretch = [0 1 0 1];
  version.RowSpan = [1 1];
  version.ColSpan = [1 1];
  version.Items = {creatorEditLbl, creatorEdit, ...
                   lastByValLbl, lastByVal, ...
                   createdEditLbl, createdEdit, ...
                   lastOnVerValLbl, lastOnVerVal, ...
                   readOnly, ...             
                   modelVerValLbl, modelVerVal};   
  version.Tag = 'Version';
               
  % History widget
  history.Name = DAStudio.message('Simulink:dialog:ModelHistoryName');
  history.Tag = history.Name;
  history.Type = 'editarea';
  history.RowSpan = [1 1];
  history.ColSpan = [1 2];
  history.ObjectProperty = 'ModifiedHistory';
   
  promptHistoryVal.Name = DAStudio.message('Simulink:dialog:ModelPromptHistoryValName');
  promptHistoryVal.Tag = promptHistoryVal.Name;
  promptHistoryVal.RowSpan = [2 2];
  promptHistoryVal.ColSpan = [2 2];
  promptHistoryVal.Type = 'combobox';
  
  promptHistoryVal.Entries = {DAStudio.message('Simulink:dialog:ModelPromptHistoryValEntryNever'), ... 
                              DAStudio.message('Simulink:dialog:ModelPromptHistoryValEntryWhenSavingModel')};
  if (strcmp(h.UpdateHistory, 'UpdateHistoryNever') == 1)
      promptHistoryVal.Value = 1;
  else
      promptHistoryVal.Value = 2;
  end
  promptHistoryVal.ObjectProperty = 'UpdateHistory';
  
  spacerPnl.Type = 'panel';
  spacerPnl.RowSpan = [2 2];
  spacerPnl.ColSpan = [1 1];
  spacerPnl.Tag = 'SpacerPnl';
  
  modelHistoryPanel.Type = 'panel';
  modelHistoryPanel.LayoutGrid = [2 2];
  modelHistoryPanel.RowSpan = [2 2];
  modelHistoryPanel.ColSpan = [1 1];
  modelHistoryPanel.RowStretch = [1 0];
  modelHistoryPanel.ColStretch = [1 0];
  modelHistoryPanel.Items = {history, spacerPnl, promptHistoryVal};
  modelHistoryPanel.Tag = 'ModelHistoryPanel';
  
  %------------------------------------------------------------------------
  % Tab Four contains:
  % - Description edit area
  %------------------------------------------------------------------------
  % Description Edit Area
  description.Name = DAStudio.message('Simulink:dialog:ModelDescriptionName');
  description.Type = 'editarea';
  description.ObjectProperty = 'Description';
  description.Tag = 'Model description:';
   
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  

  tab1.Name = DAStudio.message('Simulink:dialog:ModelTabOneName');
  tab1.LayoutGrid = [1 1];
  tab1.Items = {info};
  tab1.Tag = 'TabOne';
  
  tab2.Name = DAStudio.message('Simulink:dialog:ModelTabTwoName');
  tab2.LayoutGrid = [1 2];
  tab2.ColStretch = [1 2];
  tab2.Items = {cbTree, cbStack};
  tab2.Tag = 'TabTwo';
                  
  tab3.Name = DAStudio.message('Simulink:dialog:ModelTabThreeName');
  tab3.LayoutGrid = [2 1];
  tab3.RowStretch = [0 1];
  tab3.Items = {version, modelHistoryPanel};
  tab3.Tag = 'TabThree';
    
  tab4.Name = DAStudio.message('Simulink:dialog:ModelTabFourName');
  tab4.Items = {description};
  tab4.Tag = 'TabFour';
  
  tabcont.Type = 'tab';
  tabcont.Tabs = {tab1 tab2 tab3 tab4};
  tabcont.Tag = 'Tabcont';
  dlgstruct.Items = {tabcont};
 
  % Do the rest of assignments for this dialog
  dlgstruct.DialogTitle      = DAStudio.message('Simulink:dialog:ModelDialogTitle');
  dlgstruct.SmartApply       = 0;
  dlgstruct.PostApplyArgs    = {'%dialog'};
  dlgstruct.PostApplyCallback= 'refreshdlg';
  dlgstruct.HelpMethod       = 'helpview';
  dlgstruct.HelpArgs         = {[docroot '/mapfiles/simulink.map'], 'modelpropertiesdialog'};
  dlgstruct.DialogTag        = name;
%-------------------------- End of main function ----------------------------

%----------------------------------------------------------------------------
function htm = model_info_l(h)

if isequal(h.Dirty, 'on')  
    isModifiedStr = '<font color=''red''>yes</font>';
else                       
    isModifiedStr = 'no';
end;

numContStates     = NaN;
numDiscStates     = NaN;
numOutputs        = NaN;
numInputs         = NaN;
directFeedthrough = NaN;
numSampleTimes    = NaN;

X = get_param(h.Name, 'tag');
X = str2num(X);

if length(X) == 6,
numContStates     = X(1);
numDiscStates     = X(2);
numOutputs        = X(3);
numInputs         = X(4);
directFeedthrough = X(5);
numSampleTimes    = X(6);
end;

 % xlate is for translation purpose  
 % qshi: use DAStudio.message intead of xlate
 str = ['<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
        '<tr><td>', ...
        '<b><font size=+3>', DAStudio.message('Simulink:dialog:ModelHTMLTextModelInfoFor'), ' <a href="matlab:%s">%s</a></b></font>', ...
        '<table>',...
        '<tr><td align="right"><b>', DAStudio.message('Simulink:dialog:ModelHTMLTextSourceFile'), '</b></td><td><a href="matlab:edit(%s)">%s</a></td></tr>', ...   
        '<tr><td align="right"><b>', DAStudio.message('Simulink:dialog:ModelHTMLTextLastSaved'), '</b></td><td>%s</td></tr>', ...
        '<tr><td align="right"><b>', DAStudio.message('Simulink:dialog:ModelHTMLTextCreatedOn'), '</b></td><td>%s</td></tr>', ...
        '<tr><td align="right"><b>', DAStudio.message('Simulink:dialog:ModelHTMLTextIsModified'), '</b></td><td>', isModifiedStr,'</td></tr>', ...
        '<tr><td align="right"><b>', DAStudio.message('Simulink:dialog:ModelHTMLTextModelVersion'), '</b></td><td>%s</td></tr>', ...     
       '</table>', ...
       '</td></tr>', ...
       '</table>',...
        ];
 
% Add this back in when we have the internal APIs setup. 
% ALSO, add Model block's references and libraries referenced as well. See g172677 for more details.
%
%       '   <br><br>',...
%       '<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0>',...
%       '<tr><td>',...
%       '<b><font size=+2>Last Update Diagram Summary</font></b> ( <a href="matlab:%s">Execute Update Diagram</a> )', ...
%       '<table>',...
%       '<tr><td align="right"><b>Number of continuous states:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Number of discrete states:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Number of outputs:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Number of inputs:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Direct Feedthrough:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Number of sample times:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Library dependencies:</b></td><td>TBD</td></tr>', ...
%       '</table>', ... 
%       '</td></tr>', ...
%       '</table>' ...
%        ];
        
 editStr =  ['''' h.FileName ''''];
 execStr = ['try,[t_,rs_] = sldiagnostics(''', h.Name, ''',''Sizes''); c_ = struct2cell(rs_); d_ = [c_{:}]; set_param(''',h.Name,''',''tag'', num2str(d_));  clear(''t_''); clear(''rs_''); clear(''c_''); clear (''d_'');end;']; 
 
 htm = sprintf(str, h.Name, h.Name, editStr, h.FileName,  h.LastModifiedDate, ...
               h.Created, h.ModelVersion);
 
% execStr, numContStates, numDiscStates, ...
%               numOutputs, numInputs, directFeedthrough, numSampleTimes ...
%               );

%---------------------------------------------------------------------------------
function htm = ws_info_1

htm = ...
    ['<p>', DAStudio.message('Simulink:dialog:ModelHTMLTextHtmLineOne'), '<br>', ...
     '<ul>', ...
     '<li>', DAStudio.message('Simulink:dialog:ModelHTMLTextHtmLineThree'), ...
     '<li>', DAStudio.message('Simulink:dialog:ModelHTMLTextHtmLineFour'), ...
     '<li>', DAStudio.message('Simulink:dialog:ModelHTMLTextHtmLineFive'), ...
     '<li>', DAStudio.message('Simulink:dialog:ModelHTMLTextHtmLineSix'), ...
     '<li>', DAStudio.message('Simulink:dialog:ModelHTMLTextHtmLineSeven'), ...
     '</ul></p>', ...
     '<p>', DAStudio.message('Simulink:dialog:ModelHTMLTextHtmLineNine'), ' <br>',...
     '<div style="font-family: courier">',...
     '>> <a href="matlab:eval(''ws = get_param(bdroot, ''''BlockDiagramWorkspace'''')'')">',...
     'ws = get_param(bdroot, ''BlockDiagramWorkspace'') ',...
     '</div></p>'];
