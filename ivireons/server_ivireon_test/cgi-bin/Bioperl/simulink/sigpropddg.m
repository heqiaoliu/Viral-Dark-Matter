function dlgstruct = sigpropddg(h)
% SIGPROPDDG Dynamic dialog for signal properties dialog

% To lauch this dialog in MATLAB, use:
%    >> vdp     % load a model
%    Right click on a line and select "Signal Properties..."
  
% Copyright 1990-2010 The MathWorks, Inc.
% $Revision: 1.1.6.23 $

  % For performance reasons, we create sigObjCache regardless the status of
  % the feature 'SignalObjectAttribOnPort'. Lock this MATLAB file to prevent
  % the cache from being cleared when there is a dialog open.
  mlock;
  persistent sigObjCache; 

  if ~exist('h', 'var')
      % This handles the special call signature that is used for testing only.
      % If h is not passed in, the persistent variable sigObjCache is returned.
      % This way, tests can verify content of the persistent variable.
      dlgstruct = sigObjCache;
      return;
  end

  portObj = [];
  lineObj = [];
  if isa(h, 'Simulink.Line')
    lineObj = h;
    portObj = h.getSourcePort;
  elseif isa(h, 'Simulink.Port')
    portObj = h;
  end

  %-----------------------------------------------------------------------------
  % Cache for template signal objects used when editing signal properties
  % without workspace object.
  %
  % Format:
  %     sigObjCache
  %         Editing   % cell array; keeping port handle of open dialogs
  %             [portH1,  portH2,  ...],
  %             [RTWInfoBackup1, RTWInfoBackup2, ....]
  %
  %             RTWInfoBackup is a structure to restored the most recently applied
  %             values of attributes of the port object in case of 
  %             a Cancel operation .
  %
  %             RTWInfoBackup.StorageClass:  hPort.RTWStorageClass
  %             RTWInfoBackup.TypeQualifier: hPort.RTWStorageTypeQualifier
  %             RTWInfoBackup.SignalObject:  hPort.SignalObject
  % 
  %         ActiveTab % double
  %-----------------------------------------------------------------------------
  featSigOnPort = feature('SignalObjectAttribOnPort');
  if featSigOnPort
      if isempty(sigObjCache)
          sigObjCache = Simulink.SigpropDDGCache;
      end
  else
      sigObjCache = [];
  end

  if isempty(portObj)
      txt.Name              = DAStudio.message('Simulink:dialog:SigpropEmptyPortObjTxtName');
      txt.Type              = 'text';
      txt.RowSpan           = [1,1];
      txt.WordWrap          = true;
      txt.Tag         	    = 'Txt';
      spacer.Type           = 'panel';
      spacer.RowSpan        = [2,2];
      spacer.Tag	    = 'Spacer';
      dlgstruct.Items       = {txt, spacer};
      dlgstruct.LayoutGrid  = [2, 1];
      dlgstruct.RowStretch  = [0, 1];
      dlgstruct.DialogTitle = DAStudio.message('Simulink:dialog:SigpropEmptyPortObjDialogTitle');
      return
  end
  %------------------------------------------------------------------------
  % First Tab
  %------------------------------------------------------------------------
  
  %---------------------------------------
  % first subgroup
  %---------------------------------------
  chkLogSigData.Tag              = 'chkLogSigData';
  chkLogSigData.Type             = 'checkbox';
  chkLogSigData.Name             = DAStudio.message('Simulink:dialog:SigpropChkLogSigDataName');
  chkLogSigData.ObjectProperty   = 'DataLogging';
  chkLogSigData.Mode             = 1; % immediate mode
  chkLogSigData.DialogRefresh    = true;
  chkLogSigData.ColSpan          = [1 1];

  chkTestPoint.Tag               = 'chkTestPoint';
  chkTestPoint.Type              = 'checkbox';
  chkTestPoint.Name              = DAStudio.message('Simulink:dialog:SigpropChkTestPointName');
  chkTestPoint.ObjectProperty    = 'TestPoint';
  chkTestPoint.ColSpan           = [2 2]; 
  chkTestPoint.Enabled           = true; 
  chkTestPoint.DialogRefresh     = true;
  chkTestPoint.Mode              = 1; % immediate mode
  
  spacer1.Tag                    = 'spacer1';
  spacer1.Type                   = 'panel';
  spacer1.ColSpan                = [3 3];
  
  pnl1.Tag                       = 'pnl1';
  pnl1.Type                      = 'panel';
  pnl1.LayoutGrid                = [1 3];
  pnl1.Items                     = {chkLogSigData, chkTestPoint, spacer1};
  pnl1.ColStretch                = [0 0 1];
  pnl1.RowSpan                   = [1 1];
 
  %---------------------------------------
  %second subgroup
  %---------------------------------------
  cmbLog.Tag                     = 'cmbLog';
  cmbLog.Type                    = 'combobox';
  cmbLog.ObjectProperty          = 'DataLoggingNameMode'; 
  cmbLog.Values                  = [0 1];
  cmbLog.Entries                 = {DAStudio.message('Simulink:dialog:SigpropCmbLogEntryUseSignalName'), ...
                                    DAStudio.message('Simulink:dialog:SigpropCmbLogEntryCustom')};
  cmbLog.Mode                    = 1; % immediate mode
  cmbLog.DialogRefresh           = true;
  cmbLog.ColSpan                 = [1 1];
  cmbLog.Enabled                 = convertToBool(portObj.dataLogging);
  
  txtName.Tag                    = 'txtName';
  txtName.Type                   = 'edit';
  txtName.ObjectProperty         = 'UserSpecifiedLogName';
  txtName.ColSpan                = [2 2];
  txtName.Enabled                = convertToBool(portObj.dataLogging) && ~(isequal(portObj.dataLoggingNameMode, 'SignalName'));
  txtName.Mode                   = 1; %immediate mode
  
  grpLog.Tag                     = 'grpLog';
  grpLog.Type                    = 'group';
  grpLog.Name                    = DAStudio.message('Simulink:dialog:SigpropGrpLogName');
  grpLog.LayoutGrid              = [1 2];
  grpLog.Items                   = {cmbLog, txtName};
  grpLog.RowSpan                 = [2 2];

  %---------------------------------------  
  % third subgroup
  %---------------------------------------
  chkDataPoints.Tag              = 'chkDataPoints';
  chkDataPoints.Type             = 'checkbox';
  chkDataPoints.RowSpan          = [1 1];
  chkDataPoints.ColSpan          = [1 1];
  chkDataPoints.ObjectProperty   = 'DataLoggingLimitDataPoints';
  chkDataPoints.Enabled          = convertToBool(portObj.dataLogging);
  chkDataPoints.DialogRefresh    = true;
  chkDataPoints.Mode             = 1;
  
  lblDataPoints.Tag              = 'lblDataPoints';
  lblDataPoints.Type             = 'text';
  lblDataPoints.Name             = [DAStudio.message('Simulink:dialog:SigpropLblDataPointsName'), ' '];
  lblDataPoints.RowSpan          = [1 1];
  lblDataPoints.ColSpan          = [2 2];
  lblDataPoints.Enabled          = convertToBool(portObj.dataLogging);
    
  txtDataPoints.Tag              = 'txtDataPoints';
  txtDataPoints.Type             = 'edit';
  txtDataPoints.ObjectProperty   = 'DataLoggingMaxPoints';
  txtDataPoints.RowSpan          = [1 1];
  txtDataPoints.ColSpan          = [3 3];
  txtDataPoints.Enabled          = convertToBool(portObj.dataLogging) && convertToBool(portObj.DataLoggingLimitDataPoints);
  
  chkDecimation.Tag              = 'chkDecimation';
  chkDecimation.Type             = 'checkbox';
  chkDecimation.ObjectProperty   = 'DataLoggingDecimateData';
  chkDecimation.RowSpan          = [2 2];
  chkDecimation.ColSpan          = [1 1];
  chkDecimation.Enabled          = convertToBool(portObj.dataLogging);
  chkDecimation.DialogRefresh    = 1;
  chkDecimation.Mode             = 1;
  
  lblDecimation.Tag              = 'lblDecimation';
  lblDecimation.Type             = 'text';
  lblDecimation.Name             = [DAStudio.message('Simulink:dialog:SigpropLblDecimationName'), ' '];
  lblDecimation.RowSpan          = [2 2];
  lblDecimation.ColSpan          = [2 2];
  lblDecimation.Enabled          = convertToBool(portObj.dataLogging);
  
  txtDecimation.Tag              = 'txtDecimation';
  txtDecimation.Type             = 'edit';
  txtDecimation.ObjectProperty   = 'DataLoggingDecimation';
  txtDecimation.RowSpan          = [2 2];
  txtDecimation.ColSpan          = [3 3];
  txtDecimation.Enabled          = convertToBool(portObj.DataLoggingDecimateData) && convertToBool(portObj.dataLogging);
  
  grpData.Tag                    = 'grpData';
  grpData.Type                   = 'group';
  grpData.Name                   = DAStudio.message('Simulink:dialog:SigpropGrpDataName');
  grpData.LayoutGrid             = [2 3];
  grpData.Items                  = {chkDataPoints, lblDataPoints, txtDataPoints, ...
                                    chkDecimation, lblDecimation, txtDecimation};
  grpData.RowSpan                = [3 3];
  
  groupspacer.Type               = 'panel';
  groupspacer.RowSpan            = [4 4];
  
  tab1.Tag                       = 'tab1';
  tab1.Name                      = DAStudio.message('Simulink:dialog:SigpropTabOneName');
  tab1.Items                     = {pnl1, grpLog, grpData, groupspacer};
  tab1.LayoutGrid                = [4 1];
  tab1.RowStretch                = [0 0 0 1];
 
  %---------------------------------------------------------------
  % Second Tab
  %---------------------------------------------------------------  

  editSigObj = [];  % Port signal object for editing

  if featSigOnPort 
      % The signal object stored on the port is directly edited.
      editSigObj = portObj.SignalObject;

      % If the dialog is being created (not refreshed), back RTWStorageClass,
      % RTWStorageTypeQualifier, as well as SignalObject.
      %
      % Also, create the package change listener.
      openHandleIdx = find(sigObjCache.Editing{1} == portObj.handle, 1);
      if isempty(openHandleIdx) 
          sigprop_backup_RTWInfo(sigObjCache, openHandleIdx, portObj)
          sigprop_add_listener(lineObj, sigObjCache);
      end

  end % if feature is on

  rowSpan = 1;
  tabItems = {};
  if (featSigOnPort)
      lblPackage.Tag      = 'lblPackage';
      lblPackage.Type     = 'text';
      lblPackage.Name     = DAStudio.message('Simulink:dialog:SigpropRTWPackageName');
      lblPackage.RowSpan  = [rowSpan rowSpan];
      lblPackage.ColSpan  = [1 1];
      
      packageList = Simulink.ERTTargetCC.getSigAttribPackageList(portObj.SignalObjectPackage, false);
      cmbPackage.Tag      = 'cmbPackage';
      cmbPackage.Type     = 'combobox';
      cmbPackage.Mode     = 1; % immediate mode
      cmbPackage.DialogRefresh = true;
      cmbPackage.ObjectProperty = 'SignalObjectPackage';
      cmbPackage.Entries  = packageList;
      cmbPackage.RowSpan  = [rowSpan rowSpan];
      cmbPackage.ColSpan  = [2 2];

      btnPackage.Tag      = 'btnPackage';
      btnPackage.Type     = 'pushbutton';
      btnPackage.Name     = DAStudio.message('Simulink:dialog:SigpropRTWRefreshBtn');
      btnPackage.DialogRefresh = true;
      btnPackage.MatlabMethod = 'sigprop_ddg_cb';
      btnPackage.MatlabArgs   = {'refresh_pkg_list_cb', portObj };
      btnPackage.RowSpan = [rowSpan rowSpan];
      btnPackage.ColSpan = [3 3];

      tabItems = cat(2, tabItems, { lblPackage, cmbPackage, btnPackage });
      rowSpan = rowSpan + 1;
  end

  lblStorageClass.Tag             = 'lblStorageClass';
  lblStorageClass.Type            = 'text';
  lblStorageClass.Name            = DAStudio.message('Simulink:dialog:SigpropRTWStorageClassName');
  lblStorageClass.RowSpan         = [rowSpan rowSpan];
  lblStorageClass.ColSpan         = [1 1];

  builtInStorageClasses           = { 'Auto', ...
                                      'ExportedGlobal', ...
                                      'ImportedExtern', ...
                                      'ImportedExternPointer'};
  cmbStorageClass.Tag             = 'cmbStorageClass';
  cmbStorageClass.Type            = 'combobox';
  if featSigOnPort && ~isempty(editSigObj)
      cmbStorageClass.Source          = editSigObj;
      cmbStorageClass.ObjectProperty  = 'StorageClass'; 
      cmbStorageClass.Entries         = getPropAllowedValues(editSigObj, 'StorageClass');
  else
      % Do not translate these strings 
      cmbStorageClass.ObjectProperty  = 'RTWStorageClass'; 
      cmbStorageClass.Entries         = builtInStorageClasses;
      cmbStorageClass.Values          = [0 1 2 3];
  end
  cmbStorageClass.DialogRefresh   = true;
  cmbStorageClass.Mode            = 1; % immediate mode
  cmbStorageClass.RowSpan         = [rowSpan rowSpan];
  cmbStorageClass.ColSpan         = [2 3];

  if (featSigOnPort)
      cmbStorageClass.Enabled     = true;
  else
      cmbStorageClass.Enabled     = (~isempty(portObj.Name) && ...
                                     ~convertToBool(portObj.MustResolveToSignalObject));
  end

  tabItems = cat(2, tabItems, lblStorageClass, cmbStorageClass);
  rowSpan = rowSpan + 1;

  % Create widgets for type qualifier only if the editSigObj is empty, i.e. pkgName is '--- None ---'.
  if isempty(editSigObj)
      storageClass  = portObj.RTWStorageClass;

      % The current storage classes is always a built-in
      assert(ismember(storageClass, builtInStorageClasses));

      % Always show type qualifier unless the feature is ON
      % and the storage class is 'Auto'
      showTypeQualifier = true;
      if (featSigOnPort && isequal(storageClass, 'Auto'))
          showTypeQualifier = false;
      end

      if showTypeQualifier
          % When the feature is off, we always show the type qualifier widget, 
          % but disable it when the storage class is 'Auto'.
          lblTypeQualifier.Tag            = 'lblTypeQualifier';
          lblTypeQualifier.Type           = 'text';
          lblTypeQualifier.Name           = DAStudio.message('Simulink:dialog:SigpropRTWTypeQualifierName');
          lblTypeQualifier.RowSpan        = [rowSpan rowSpan];
          lblTypeQualifier.ColSpan        = [1 1];
          
          txtTypeQualifier.Tag            = 'txtTypeQualifier';
          txtTypeQualifier.Type           = 'edit';
          txtTypeQualifier.ObjectProperty = 'RTWStorageTypeQualifier';
          txtTypeQualifier.Mode           = 1; % immediate mode
          txtTypeQualifier.RowSpan        = [rowSpan rowSpan];
          txtTypeQualifier.ColSpan        = [2 3];
          if ~featSigOnPort
              txtTypeQualifier.Enabled = ~isequal(storageClass, 'Auto');
          end
          
          rowSpan = rowSpan + 1;
          tabItems = cat(2, tabItems, lblTypeQualifier, txtTypeQualifier );
      end          
  else
      hasMoreAttributes = false;

      storageClass  = editSigObj.StorageClass;
      % 'SimulinkGlobal' is not part of the builtInStorageClasses list but does not
      % have custom attributes either.
      if (~ismember(storageClass, [ builtInStorageClasses 'SimulinkGlobal']))
          % If it is a customer storage class

          hRTWInfoClass = classhandle(editSigObj.RTWInfo);
          csAttribsProp = findprop(hRTWInfoClass, 'CustomAttributes');
          grpMoreAttributes = populate_widget_from_object_property(editSigObj.RTWInfo, csAttribsProp, editSigObj);
          if isfield(grpMoreAttributes, 'Items') && ~isempty(grpMoreAttributes)
              grpMoreAttributes.Items = align_names(grpMoreAttributes.Items);
              grpMoreAttributes.LayoutGrid = [length(grpMoreAttributes.Items) 2];
              hasMoreAttributes = true;
          end
      end

      if (hasMoreAttributes)
          grpMoreAttributes.Tag           = 'lblMoreAttributes';
          grpMoreAttributes.Name          = DAStudio.message('Simulink:dialog:DataCustomAttributesPrompt');
          grpMoreAttributes.Type          = 'group';
          grpMoreAttributes.RowSpan       = [rowSpan rowSpan];
          grpMoreAttributes.ColSpan       = [1 3];

          rowSpan = rowSpan + 1;
          tabItems = cat(2, tabItems, grpMoreAttributes );
      end
  end 

  if featSigOnPort && ~isempty(editSigObj)
      props = get(classhandle(editSigObj.RTWInfo), 'Properties');
      for i = 1:length(props)
          if ((strcmp(props(i).Name, 'StorageClass')) || ...
              (strcmp(props(i).Name, 'CustomStorageClass')) || ...
              (strcmp(props(i).Name, 'CustomAttributes')))
            continue;
          end
          
          obsoleteInitialValueProp = ((strcmp(props(i).Name, 'InitialValue')) || ...
                                      (strcmp(props(i).Name, 'InitialValueCache')) || ...
                                      (strcmp(props(i).Name, 'hParentObject')));
    
          switch slfeature('ObsoleteMPTInitialValue')
            case {0, -1} % R2009a behavior / Warning
              if obsoleteInitialValueProp
                continue;
              end
            otherwise
              assert(~obsoleteInitialValueProp);
          end

          wid = populate_widget_from_object_property(editSigObj.RTWInfo, props(i), editSigObj);
          if (strcmp(wid.Type,'unknown') == 1)
              continue;
          end;
          
          wid.MatlabMethod = 'dataddg_cb';
          wid.MatlabArgs = {0, 'refresh_me_cb', h};
          wid.RowSpan = [rowSpan rowSpan];
          wid.ColSpan = [1 3];
          wid = align_names({wid});
          
          rowSpan = rowSpan + 1;
          tabItems = cat(2, tabItems, wid );
      end
  end

  spacer4.Tag                     = 'spacer4';
  spacer4.Type                    = 'panel';
  spacer4.RowSpan                 = [rowSpan rowSpan];
  spacer4.ColSpan                 = [1 3];
  tabItems{end+1}                 = spacer4;

  tab2Pnl.Tag                     = 'tab2pnl';
  tab2Pnl.Type                    = 'panel';
  tab2Pnl.Enabled                 = ~featSigOnPort || ...
                                    ~isempty(portObj.Name) && isequal(portObj.MustResolveToSignalObject,'off');
  tab2Pnl.Items                   = tabItems;
  tab2Pnl.LayoutGrid              = [rowSpan 3];
  tab2Pnl.ColSpan                 = [1 2];
  tab2Pnl.RowSpan                 = [1 1];
  tab2Pnl.ColStretch              = [0 1 0];
  tab2Pnl.RowStretch              = [zeros(1, rowSpan-1) 1];

  tab2.Tag                        = 'tab2';
  tab2.Name                       = DAStudio.message('Simulink:dialog:SigpropTabTwoName');
  tab2.Items                      = { tab2Pnl };
  
  tab2.LayoutGrid                 = [1 1];

  
  %---------------------------------------------------------------
  %Third Tab
  %---------------------------------------------------------------
  lblDescription.Tag              = 'lblDescription';
  lblDescription.Type             = 'text';
  lblDescription.Name             = DAStudio.message('Simulink:dialog:SigpropLblDescriptionName');
  lblDescription.RowSpan          = [1 1];
  
  txtDescription.Name             = lblDescription.Name;
  txtDescription.HideName         = true;
  txtDescription.Tag              = 'txtDescription';
  txtDescription.Type             = 'editarea';
  txtDescription.RowSpan          = [2 2];
  txtDescription.ObjectProperty   = 'Description';
  
  hypLink.Tag                     = 'hypLink';
  hypLink.Type                    = 'hyperlink';
  hypLink.Name                    = DAStudio.message('Simulink:dialog:SigpropHyplinkName');

  % See geck 510039.
  if slfeature('SignalDialogHyperlinkResolvesToEval')
      linkCmd = 'eval';
  else
      linkCmd = 'doc';
  end
  hypLink.MatlabMethod            = linkCmd;
  
  hypLink.MatlabArgs              = {portObj.documentLink};
  hypLink.RowSpan                 = [3 3];
  
  txtLink.Tag                     = 'txtLink';
  txtLink.Type                    = 'edit';
  txtLink.ObjectProperty          = 'documentLink';
  txtLink.RowSpan                 = [4 4];
 
  tab3.Tag                        = 'tab3';
  tab3.Name                       = DAStudio.message('Simulink:dialog:SigpropTabThreeName');
  tab3.LayoutGrid                 = [4 1];
  tab3.Items                      = {lblDescription ...
                                     txtDescription ...
                                     hypLink ...
                                     txtLink};
 
  %--------------------------------------------------------------
  % better for separate widgets
  %--------------------------------------------------------------
  lblSignalName.Tag               = 'lblSignalName';
  lblSignalName.Name              = DAStudio.message('Simulink:dialog:SigpropLblSignalNameName');
  lblSignalName.Type              = 'text';
  lblSignalName.RowSpan           = [1 1];
  lblSignalName.ColSpan           = [1 1];
  
  txtSignalName.Tag               = 'txtSignalName';
  txtSignalName.Type              = 'edit';
  txtSignalName.ObjectProperty    = 'SignalNameFromLabel';
  txtSignalName.Mode              = 1; % immediate mode
  txtSignalName.DialogRefresh     = true;
  txtSignalName.RowSpan           = [1 1];
  txtSignalName.ColSpan           = [2 2];
  
  lblShowSigProp.Tag              = 'lblShowSigProp';
  lblShowSigProp.Name             = DAStudio.message('Simulink:dialog:SigpropLblShowSigPropName');
  lblShowSigProp.Type             = 'text';
  lblShowSigProp.RowSpan          = [1 1];
  lblShowSigProp.ColSpan          = [3 3];
  lblShowSigProp.Visible          = portObj.supportsSignalPropagation;
  
  cmbShowSigProp.Tag              = 'cmbShowSigProp';
  cmbShowSigProp.Type             = 'combobox';
  cmbShowSigProp.ObjectProperty   = 'ShowPropagatedSignals'; 

  % Do not translate these strings
  % Do not show all for model blocks
  sourceBlock = get_param(portObj.Handle, 'Parent');
  if(isequal(get_param(sourceBlock, 'BlockType'), 'ModelReference'))
      cmbShowSigProp.Values           = [0 1];
      cmbShowSigProp.Entries          = {'off', ...		
                                        'on'};      
  else
      cmbShowSigProp.Values           = [0 1 2];
      cmbShowSigProp.Entries          = {'off', ...		
                                        'on',   ...
                                        'all'};
  end
  cmbShowSigProp.RowSpan          = [1 1];
  cmbShowSigProp.ColSpan          = [4 4];
  cmbShowSigProp.Visible          = portObj.supportsSignalPropagation;
  
  chkResSigObj.Tag                = 'MustResolveToSignalObject';
  chkResSigObj.Type               = 'checkbox';
  chkResSigObj.Name               = DAStudio.message('Simulink:dialog:SigpropChkResSigObjName');
  chkResSigObj.ObjectProperty     = 'MustResolveToSignalObject';
  chkResSigObj.Mode               = 1; % immediate mode
  chkResSigObj.DialogRefresh      = true;
  chkResSigObj.Enabled            = ~isempty(portObj.Name);
  chkResSigObj.RowSpan            = [2 2];
  chkResSigObj.ColSpan            = [1 4];
  
  tabContainer.Tag                = 'tabContainer';
  tabContainer.Name               = DAStudio.message('Simulink:dialog:SigpropTabContainerName');
  tabContainer.Type               = 'tab';
  tabContainer.Tabs           = {tab1, tab2, tab3};
  tabContainer.RowSpan            = [3 3];
  tabContainer.ColSpan            = [1 4];

  if featSigOnPort
      tabContainer.ActiveTab      = sigObjCache.ActiveTab;
      tabContainer.TabChangedCallback = 'cscuicallback';

      activeTabHelper.Tag         = [tabContainer.Tag '_ActiveTabHelper'];
      activeTabHelper.Name        = '';
      activeTabHelper.Type        = 'text';
      activeTabHelper.Visible     = false;
      activeTabHelper.UserData    = sigObjCache;
      activeTabHelper.RowSpan     = [4 4];
      activeTabHelper.ColSpan     = [4 4];
  end
  
  %---------------------------------------------------------------
  % Listener widget used to keep this port dialog in sync with 
  % the corresponding Simulink.Line
  %---------------------------------------------------------------
  
  listener.Type    = 'edit';
  listener.Visible = 0;
  listener.RowSpan = [4 4];
  listener.ColSpan = [1 4];
  
  if ~isempty(lineObj)
      cls   = classhandle(lineObj);
      props = get(cls.Properties, 'Name');
      
      listener.Source             = lineObj;
      listener.ListenToProperties = props';
  end  
  
  %---------------------------------------------------------------
  % Main Dialog
  %---------------------------------------------------------------
  
  % IMPORTANT: This tag should be the same as that defined in 
  %            toolbox/simulink/simulink/slfind.m in i_FindOpenDDGDialog.
  dlgstruct.DialogTag             = strcat('Port Properties: ', num2str(portObj.handle,16));
  
  dlgstruct.DialogTitle           = DAStudio.message('Simulink:dialog:SigpropPortObjDlgStructDialogTitle', portObj.Name);
  dlgstruct.Items                 = {lblSignalName,  txtSignalName,  ...
                                     chkResSigObj, ...
                                     lblShowSigProp, cmbShowSigProp, ...
                                     tabContainer, ...
                                     listener};
  if featSigOnPort
      dlgstruct.Items             = [dlgstruct.Items, {activeTabHelper}];
  end
  dlgstruct.LayoutGrid            = [4 4];
  dlgstruct.RowStretch            = [0 0 1 0];
  dlgstruct.ColStretch            = [0 1 0 0];
  
  if isa(portObj, 'handle')
    dlgstruct.Source              = portObj;
  end

  dlgstruct.PreApplyCallback      = 'sigprop_ddg_cb';
  dlgstruct.PreApplyArgs          = {'preapply_cb', portObj, sigObjCache};
  
  dlgstruct.PostApplyCallback     = 'sigprop_ddg_cb';
  dlgstruct.PostApplyArgs         = {'postapply_cb', portObj, lineObj};

  dlgstruct.CloseCallback         = 'sigprop_ddg_cb';
  dlgstruct.CloseArgs             = {'close_cb', portObj, '%closeaction', sigObjCache};
  
  % Clicking the "Revert" button in the Model Explorer is treated the same
  % as clicking the "Cancel" button on a stand-alone dialog.
  dlgstruct.PostRevertCallback    = 'sigprop_ddg_cb';
  dlgstruct.PostRevertArgs        = {'postrevert_cb', portObj, lineObj, sigObjCache};

  dlgstruct.DisableDialog         = ~isa(portObj, 'handle') || ...
                                    h.isHierarchySimulating;
  dlgstruct.HelpMethod            = 'slprophelp';
  dlgstruct.HelpArgs              = {'signal'};
  
  dlgstruct.DialogRefresh      = true;
end

%--------------------------------------------------------------------------------  
function ret = convertToBool(x)
    if(isa(x, 'logical'))
        ret = x;
    else %it must be a string
        
        ret = strcmp(x, 'on');
    end
end
    

%--------------------------------------------------------------------------------  
% Register a listener to the PropertyChangedEvent and store the handle to the listener
% in sigObjCache
function sigprop_add_listener(lineObj, sigObjCache)
    openHandleIdx = length(sigObjCache.Editing{3}) + 1;
    assert(~isempty(sigObjCache.Editing{1}(openHandleIdx)));

    if isempty(lineObj)
        propertyChangedEventListener = [];
    else
        propertyChangedEventListener = handle.listener(lineObj, ...
                                                       'LinePropertyChangedEvent', ...
                                                       { @handle_property_changed_event, openHandleIdx, sigObjCache });
    end

    sigObjCache.Editing{3} = [sigObjCache.Editing{3}, {propertyChangedEventListener}];
end


%--------------------------------------------------------------------------------  
% This listener handles ProperthChangedEvent caused by the modification of 
% the properties or properties of sub-objects of a particular line object
% It backs-up the RTWStorageClass, RTWStorageTypeQualifier and SignalObject properties
%
% This ensures that the changes in the ME list view will be backed-up and restored during
% revert or cancel operations.
%
function handle_property_changed_event(~, eventData, openHandleIdx, sigObjCache)
    lineObj = eventData.Source;

    assert(~isempty(lineObj) && lineObj.isa('Simulink.Line')); 
    portObj = lineObj.getSourcePort;
    if (portObj == sigObjCache.Editing{1}(openHandleIdx)) 
        sigprop_backup_RTWInfo(sigObjCache, openHandleIdx, portObj);
    end
end

