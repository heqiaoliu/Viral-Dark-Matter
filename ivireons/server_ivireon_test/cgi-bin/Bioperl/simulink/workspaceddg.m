function dlgstruct = workspaceddg(hObj)
% WORKSPACEDDG Creates the workspace dialog in the Model Explorer.
%   This function manages and displays the workspace dialog in the 
%   in the Model Explorer.
%
%   The GUI layout looks like this:
%
%     For MDL-File data source:
%
%        Model Workspace
%           Workspace data
%
%           Data source: MDL-File____________________________________________
%
%
%     For MAT-File data source:
%
%        Model Workspace
%           Workspace data
%
%           Data source: MAT-File____________________________________________
%           File name: Foo.mat_______________________________________________
%           [Reinitialize from Source] [Save to Source]
%
%
%     For MATLAB File data source:
%
%        Model Workspace
%           Workspace data
%
%           Data source: MATLAB File____________________________________________
%           File name: Foo.m_______________________________________________
%           [Reinitialize from Source] [Save to Source]
%
%
%     For MATLAB Code data source:
%
%        Model Workspace
%           Workspace data
%
%           Data source: MATLAB Code______________________________________________
%           MATLAB Code:
%           .---------------------------------------------------------------.
%           | Kp = 37;                                                      |
%           | Cp = 9.27;                                                    |
%           |                                                               |
%           `---------------------------------------------------------------'
%           [Reinitialize from Source]
%
%
%
%   Widget types:
%      [<text>]     =>  Button
%      Data source  =>  Combobox
%      File name    =>  Edit field
%      MATLAB Code       =>  Edit area

% To launch this dialog in MATLAB, use:
%    >> vdp          % load a model
%    >> daexplr      % launch the Design Automation Model Explorer
%    In the "Model Hierarchy", select Simulink Root->vdp->Model Workspace.

% Copyright 1990-2010 The MathWorks, Inc.
% $Revision: 1.1.6.17 $

if isa(hObj, 'DAStudio.WorkspaceNode')
    hObj = hObj.getParent;
end

if (isa(hObj, 'Simulink.Root'))
    BaseWrkSpaceDesc.Type = 'textbrowser';
    BaseWrkSpaceDesc.Text = l_BaseWSInfo;
    BaseWrkSpaceDesc.Tag = 'BaseWrkSpaceDesc';

    dlgstruct.DialogTitle = DAStudio.message('Simulink:dialog:WorkspaceRootDlgStructDialogTitle');
    dlgstruct.Items = {BaseWrkSpaceDesc};
    dlgstruct.HelpMethod  = 'helpview';
    dlgstruct.HelpArgs    = {[docroot '/mapfiles/simulink.map'], 'base_workspace'};
else
    hWS = hObj.getWorkspace;

    % Flags used to enable/disable fields
    isMDLSrc   = false;
    isMATSrc   = false;
    isMFileSrc = false;
    isMCodeSrc = false;

    switch hWS.DataSource
     case 'MDL-File'
      isMDLSrc   = true;
     case 'MAT-File'
      isMATSrc   = true;
     case 'MATLAB File'
      isMFileSrc = true;
     case 'MATLAB Code'
      isMCodeSrc = true;
     otherwise
      DAStudio.error('Simulink:dialog:WorkspaceDataSourceError', hWS.DataSource);
    end

    % Source Combo Box
    source.Name          = DAStudio.message('Simulink:dialog:WorkspaceSourceName');
    source.Tag           = 'dataSource';
    source.RowSpan       = [1 1];
    source.ColSpan       = [1 4];
    source.Type          = 'combobox';
    source.DialogRefresh = 1;
    source.Entries       = {'MDL-File', 'MAT-File', 'MATLAB File', 'MATLAB Code'};	
    source.Values        = ...
        [workspaceddg_cb([], 'mapDataSourceToValue', hWS, 'MDL-File'), ...
         workspaceddg_cb([], 'mapDataSourceToValue', hWS, 'MAT-File'), ...
         workspaceddg_cb([], 'mapDataSourceToValue', hWS, 'MATLAB File'), ...
         workspaceddg_cb([], 'mapDataSourceToValue', hWS, 'MATLAB Code')];
    source.Value         = workspaceddg_cb([], 'mapDataSourceToValue', hWS, hWS.DataSource);
    source.MatlabMethod  = 'workspaceddg_cb';
    source.MatlabArgs    = {'%dialog', '%tag', hWS, '%value'};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Data Source-specific elements
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % File Name
    fileEdit.Name                 = DAStudio.message('Simulink:dialog:WorkspaceFileEditName');
    fileEdit.Tag                  = 'WorkspaceFileName';
    fileEdit.RowSpan              = [2 2];
    fileEdit.ColSpan              = [1 3];
    fileEdit.Type                 = 'edit';
    fileEdit.Visible              = isMATSrc||isMFileSrc;
    if isMATSrc||isMFileSrc
      fileEdit.Source             = hWS;
      fileEdit.ObjectProperty     = 'FileName';
      fileEdit.Mode               = 1;
      fileEdit.DialogRefresh      = 1;
    end
    fileEdit.ToolTip              = DAStudio.message('Simulink:dialog:WorkspaceFileEditToolTip');

    % File Browser Button
    fileBrowserButton.Name             = DAStudio.message('Simulink:dialog:WorkspaceFileBrowserButtonName');
    fileBrowserButton.Tag              = 'WorkspaceFileBrowser';
    fileBrowserButton.RowSpan          = [2 2];
    fileBrowserButton.ColSpan          = [4 4];
    fileBrowserButton.Type             = 'pushbutton';
    fileBrowserButton.Visible          = isMATSrc||isMFileSrc;
    fileBrowserButton.MatlabMethod     = 'workspaceddg_cb';
    fileBrowserButton.MatlabArgs       = {'%dialog', '%tag', hWS};
    fileBrowserButton.DialogRefresh    = 1;
    fileBrowserButton.Enabled          = 1;
    fileBrowserButton.ToolTip          = DAStudio.message('Simulink:dialog:WorkspaceFileBrowserButtonToolTip');

    % User MATLAB Code Edit Area
    userMcode.Name                = DAStudio.message('Simulink:dialog:WorkspaceUserMCodeName');
    userMcode.Tag                 = 'MATLABCode';
    userMcode.RowSpan             = [3 3];
    userMcode.ColSpan             = [1 4];
    userMcode.Type                = 'editarea';
    userMcode.Visible             = isMCodeSrc;
    if isMCodeSrc
      userMcode.Source            = hWS;
      userMcode.ObjectProperty    = 'MATLABCode';
      userMcode.Mode              = 1;
      userMcode.DialogRefresh     = 1;
    end
    userMcode.ToolTip             = DAStudio.message('Simulink:dialog:WorkspaceUserMCodeToolTip');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The Reload (Reinitialize) is valid for MAT-File and MATLAB Code data sources. The
    % "Save to Source" button is only valid for the MAT-File data source.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Reload (Reinitialize) Button
    reloadButton.Name             = DAStudio.message('Simulink:dialog:WorkspaceReloadButtonName');
    reloadButton.Tag              = 'reload';
    reloadButton.RowSpan          = [4 4];
    reloadButton.ColSpan          = [1 1];
    reloadButton.Type             = 'pushbutton';
    reloadButton.Visible          = ~isMDLSrc;
    reloadButton.MatlabMethod     = 'workspaceddg_cb';
    reloadButton.MatlabArgs       = {'%dialog', '%tag', hWS};
    reloadButton.DialogRefresh    = 1;
    reloadButton.Enabled          = ((isMATSrc||isMFileSrc) && filenameNonEmpty(hWS)) || ...
                                    (isMCodeSrc && ~isempty(hWS.MATLABCode)); %||wsIsDirty(hWS);
    reloadButton.ToolTip          = DAStudio.message('Simulink:dialog:WorkspaceReloadButtonToolTip');

    % "Save to Source" Button
    savetosrcButton.Name          = DAStudio.message('Simulink:dialog:WorkspaceSavetosrcButtonName');
    savetosrcButton.Tag           = 'saveToSource';
    savetosrcButton.RowSpan       = [4 4];
    savetosrcButton.ColSpan       = [2 2];
    savetosrcButton.Type          = 'pushbutton';
    savetosrcButton.Visible       = isMATSrc||isMFileSrc;
    savetosrcButton.MatlabMethod  = 'workspaceddg_cb';
    savetosrcButton.MatlabArgs    = {'%dialog', '%tag', hWS};
    savetosrcButton.DialogRefresh = 1;
    savetosrcButton.Enabled       = filenameNonEmpty(hWS) && wsIsDirty(hWS) && ~wsIsEmpty(hWS);
    savetosrcButton.ToolTip       = DAStudio.message('Simulink:dialog:WorkspaceSavetosrcButtonToolTip');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The spacer between buttons.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Spaces the buttons apart
    spacer.RowSpan                = [5 5];
    spacer.ColSpan                = [1 1];
    spacer.Type                   = 'panel';

    pnlModelWrkSpace.Name         = DAStudio.message('Simulink:dialog:WorkspacePnlModelWrkSpaceName');
    pnlModelWrkSpace.Type         = 'group';
    pnlModelWrkSpace.RowSpan      = [1 1];
    pnlModelWrkSpace.ColSpan      = [1 1];
    pnlModelWrkSpace.LayoutGrid   = [4 4];
    pnlModelWrkSpace.ColStretch   = [0 0 1 0];
    pnlModelWrkSpace.Items        = ...
        {source, fileEdit, fileBrowserButton, userMcode, ...
         reloadButton, savetosrcButton,  ...
         spacer}; 
    pnlModelWrkSpace.Tag	  = 'PnlModelWrkSpace';

    % Parameter Argument Names
    modelArgNames.Name            = DAStudio.message('Simulink:dialog:WorkspaceModelArgNamesName');
    modelArgNames.NameLocation    = 2;
    modelArgNames.RowSpan         = [2 2];
    modelArgNames.ColSpan         = [1 1];
    modelArgNames.Type            = 'edit';
    modelArgNames.Tag             = 'ModelParamArgNames';
    modelArgNames.Source          = hObj.Handle;
    modelArgNames.ObjectProperty  = 'ParameterArgumentNames';
    modelArgNames.ToolTip         = DAStudio.message('Simulink:dialog:WorkspaceModelArgNamesToolTip');
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assemble the dialog
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    spacer.RowSpan         = [3 3];
    spacer.ColSpan         = [1 1];
    spacer.Type            = 'panel';
    spacer.Tag		   = 'Spacer';

    dlgstruct.DialogTitle  = DAStudio.message('Simulink:dialog:WorkspaceDlgStructDialogTitle');
    dlgstruct.LayoutGrid   = [3 1];
    dlgstruct.RowStretch   = [0 0 1];
    dlgstruct.Items        = {pnlModelWrkSpace, modelArgNames, spacer};
    
    dlgstruct.PostApplyCallback = 'workspaceddg_cb';
    dlgstruct.PostApplyArgs     = {'%dialog', 'postApply', hWS};
    
    % Do the rest of assignments for this dialog
    dlgstruct.SmartApply   = 0;
    dlgstruct.HelpMethod   = 'helpview';
    dlgstruct.HelpArgs     = {[docroot '/mapfiles/simulink.map'], 'model_workspace'};
end

%-----------------------------------------------------------------------------
function result = filenameNonEmpty(hWS)

  result = ((strcmp(hWS.DataSource, 'MAT-File') || strcmp(hWS.DataSource, 'MATLAB File')) ... 
            && ~strcmp(strtrim(hWS.FileName), '') );

%-----------------------------------------------------------------------------
function result = wsIsEmpty(hWS)  

  result = isempty(hWS.whos);

%-----------------------------------------------------------------------------
function result = wsIsDirty(hWS)

  result = false;

  if islogical(hWS.isDirty) && hWS.isDirty
    result = true;
  end

%-----------------------------------------------------------------------------
function htm = l_BaseWSInfo

htm = ['<p>', DAStudio.message('Simulink:dialog:WorkspaceHTMLText') , '<\p>'];
