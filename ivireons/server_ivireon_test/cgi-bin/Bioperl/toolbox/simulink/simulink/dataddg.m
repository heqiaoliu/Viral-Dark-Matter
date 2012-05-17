function dlgOrPanel = dataddg(h, name, type, varargin)
% DATADDG Dynamic dialog for Simulink data objects.

% To launch this dialog in MATLAB, use:
%    >> a = SimulinkDemos.Signal;
%    >> DAStudio.Dialog(a);
% or
%    >> b = SimulinkDemos.Parameter;
%    >> b.Value = int8(5);
%    >> DAStudio.Dialog(b);
% or
%    >> c = mpt.Parameter;
%    >> c.Value = 2.3;
%    >> c.DataType = 'fixdt(true, 8, 2^-3, 0)';
%    >> DAStudio.Dialog(c);
   

% Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.47 $ $Date: 2010/04/21 21:59:07 $

  isRtnPanel = false;
  if nargin == 4
      if islogical(varargin{1})
          isRtnPanel = varargin{1};
      else
          DAStudio.error('Simulink:dialog:InvalidArgFourExpLogStat');
      end
  end

  % Set flag for signal or parameter object
  if ~strcmp(type, 'signal')
      isParam               = true;
      % Set parameter tag for unified data type
      valueEdit.Tag         = 'ValueEdit';
  else
      isParam               = false;      
      % Set signal for unified data type
      initialValue.Tag      = 'InitialValue';
  end
    
  %------------------------------------------------------------------------
  % Row One contains a panel with:
  % - Common widgets (minimum, maximum, units and associated labels)
  % - Parameter widets (Value, DataType, Dimensions and Complexity) -or- 
  % - Signal widgets (DataType, Dimensions, Complexity, SampleTime and SampleMode)
  %------------------------------------------------------------------------
  rowIdx = 1;
  pnlObj.Type               = 'panel';
  pnlObj.RowSpan            = [rowIdx rowIdx];
  pnlObj.ColSpan            = [1 2];
  pnlObj.Tag                = 'PnlObj';
  
  % Min and Max widgets
  minimumLbl.Name           = DAStudio.message('Simulink:dialog:DataMinimumPrompt');
  minimumLbl.Type           = 'text';
                            
  minimum.Name              = minimumLbl.Name;
  minimum.HideName          = 1;
  minimum.Type              = 'edit';
  minimum.Source            = h;
  minimum.ObjectProperty    = 'Min';
  minimum.Tag               = 'Minimum';
  minimum.ToolTip           = DAStudio.message('Simulink:dialog:DataMinimumToolTip');
                            
  maximumLbl.Name           = DAStudio.message('Simulink:dialog:DataMaximumPrompt');
  maximumLbl.Type           = 'text';
                            
  maximum.Name              = maximumLbl.Name;
  maximum.HideName          = 1;
  maximum.Type              = 'edit';
  maximum.Source            = h;
  maximum.ObjectProperty    = 'Max';
  maximum.Tag               = 'Maximum';
  maximum.ToolTip           = DAStudio.message('Simulink:dialog:DataMaximumToolTip');
                            
  % Unified DataType common to Parameter and Signal  
      
  % Add Min/ Max tags to be used for on-dialog scaling
  dataTypeItems.scalingMinTag = { minimum.Tag };
  dataTypeItems.scalingMaxTag = { maximum.Tag };
  if isParam
      dataTypeItems.scalingValueTags = { valueEdit.Tag };
      builtin = Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('Parameter');
  else
      dataTypeItems.scalingValueTags = { initialValue.Tag };
      builtin = Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('Signal');
  end
  
  % Add scaling modes/ signed unsigned modes / built-in types
  dataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
  dataTypeItems.signModes    = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
  
  dataTypeItems.builtinTypes = builtin;
  
  % Simulink data supports enumerate data type 
  dataTypeItems.supportsEnumType = true;

  if isParam && slfeature('TunableStructuredParameter') ~= 0
      dataTypeItems.supportsBusType = true;
  end

  % Signal Object will support bus types
  if ~isParam
      dataTypeItems.supportsBusType = true;
  end
  
  % Get Widget for Unified dataType
  dataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(h, ...
                                                               'DataType', ...
                                                               DAStudio.message('Simulink:dialog:DataDataTypePrompt'), ...
                                                               'DataType', ...
                                                               h.DataType, ...
                                                               dataTypeItems, ...
                                                               false);  
  
  dimensionsLbl.Name        = DAStudio.message('Simulink:dialog:DataDimensionsPrompt');
  dimensionsLbl.Type        = 'text';
  dimensionsLbl.Tag         = 'DimensionsLbl';
                            
  dimensions.Name           = dimensionsLbl.Name;
  dimensions.HideName       = 1;
  dimensions.Type           = 'edit';
  dimensions.Tag            = 'Dimensions';
  dimensions.Source         = h;
  dimensions.ObjectProperty = 'Dimensions';
  dimensions.ToolTip        = DAStudio.message('Simulink:dialog:DataDimensionsToolTip1');
  
  complexityLbl.Name        = DAStudio.message('Simulink:dialog:DataComplexityPrompt');
  complexityLbl.Type        = 'text';
  complexityLbl.Tag         = 'ComplexityLbl';
                            
  complexity.Name           = complexityLbl.Name;
  complexity.HideName       = 1;
  complexity.Type           = 'edit';
  complexity.Tag            = 'Complexity';
  complexity.Source         = h;
  complexity.ObjectProperty = 'Complexity';
  complexity.ToolTip        = DAStudio.message('Simulink:dialog:DataComplexityToolTip1');

  % Unit widgets
  unitsLbl.Name             = DAStudio.message('Simulink:dialog:DataUnitsPrompt');
  unitsLbl.Type             = 'text';
  unitsLbl.Tag              = 'UnitsLbl';
                            
  units.Name                = unitsLbl.Name;
  units.HideName            = 1;
  units.Type                = 'edit';
  units.Source              = h;
  units.ObjectProperty      = 'DocUnits';
  units.Tag                 = 'DocUnits';
  units.ToolTip             = DAStudio.message('Simulink:dialog:DataUnitsToolTip');
  
  % Handy booleans
  isParameter = false;
  isDoubleParam = false;
  
  %-------------------------------------------------------------------------
  %                     Parameter specific
  %-------------------------------------------------------------------------
  
  if isParam
      isParameter = true;
      if isequal(class(h.Value), 'double')
          isDoubleParam = true;
      end
      
      % Simulink help
      helpTopicKey = 'simulink_parameter';
      
      valueEditLbl.Name           = DAStudio.message('Simulink:dialog:ParamValuePrompt');
      valueEditLbl.Type           = 'text';
      valueEditLbl.Tag            = 'ValueEditLbl';
      
      valueEdit.Name              = valueEditLbl.Name;
      valueEdit.HideName          = 1;
      valueEdit.Type              = 'edit';
      valueEdit.Source            = h;
      valueEdit.ObjectProperty    = 'Value';
      valueEdit.Mode              = true; % Immediate apply
      valueEdit.DialogRefresh     = true; % Immediate apply
      if isDoubleParam
          valueEdit.ToolTip         = DAStudio.message('Simulink:dialog:ParamValueToolTip1');
      else
          valueEdit.ToolTip         = DAStudio.message('Simulink:dialog:ParamValueToolTip2', class(h.Value));
      end
      
      % Subordinate widgets to valueEdit END --------------
      
      %Value widget
      valueEditLbl.RowSpan        = [rowIdx rowIdx];
      valueEditLbl.ColSpan        = [1 1];
      valueEdit.RowSpan           = [rowIdx rowIdx];
      rowIdx = rowIdx + 1;    
      valueEdit.ColSpan           = [2 4];  
      
          
      % DataType widget
      dataTypeGroup.RowSpan       = [rowIdx rowIdx+1];
      dataTypeGroup.ColSpan       = [1 4];
      rowIdx = rowIdx + 2;
      
      %Dimensions and Complexity widgets
      dimensionsLbl.RowSpan       = [rowIdx rowIdx];
      dimensionsLbl.ColSpan       = [1 1];
      dimensions.RowSpan          = [rowIdx rowIdx];
      dimensions.ColSpan          = [2 2];
      dimensions.Enabled          = 0;
      dimensions.Bold             = 1;
      dimensions.ToolTip          = DAStudio.message('Simulink:dialog:DataDimensionsToolTip2');
      complexityLbl.RowSpan       = [rowIdx rowIdx];
      complexityLbl.ColSpan       = [3 3];
      complexity.RowSpan          = [rowIdx rowIdx];
      complexity.ColSpan          = [4 4];
      complexity.Enabled          = 0;
      complexity.Bold             = 1;
      complexity.ToolTip          = DAStudio.message('Simulink:dialog:DataComplexityToolTip2');
      rowIdx = rowIdx + 1;
      
      % Min and Max widgets
      minimumLbl.RowSpan          = [rowIdx rowIdx];
      minimumLbl.ColSpan          = [1 1];
      minimum.RowSpan             = [rowIdx rowIdx];
      minimum.ColSpan             = [2 2];
      maximumLbl.RowSpan          = [rowIdx rowIdx];
      maximumLbl.ColSpan          = [3 3];
      maximum.RowSpan             = [rowIdx rowIdx];
      maximum.ColSpan             = [4 4];    
      rowIdx = rowIdx + 1;
      
      % Units widget
      unitsLbl.RowSpan            = [rowIdx rowIdx];
      unitsLbl.ColSpan            = [1 1];
      units.RowSpan               = [rowIdx rowIdx];
      units.ColSpan               = [2 2];
      
      % Construct the panel widget
      pnlObj.LayoutGrid           = [rowIdx 4];
      pnlObj.ColStretch           = [0 1 0 1];
      pnlObj.Items                = {valueEditLbl, valueEdit,...
                          dataTypeGroup, ... 
                          minimumLbl, minimum, ...
                          maximumLbl, maximum, ...
                          dimensionsLbl, dimensions, ... 
                          complexityLbl, complexity,...
                          unitsLbl, units};
  else                          
      %-------------------------------------------------------------------------
      %                     Signal specific
      %-------------------------------------------------------------------------
      
      % Simulink help
      helpTopicKey = 'simulink_signal';
      
      % DataType widgets
      dataTypeGroup.RowSpan            = [rowIdx rowIdx + 1];
      dataTypeGroup.ColSpan            = [1 4];
      rowIdx = rowIdx + 2; 
      
      % Dimensions and Complexity widgets
      dimensionsLbl.RowSpan      = [rowIdx rowIdx];
      dimensionsLbl.ColSpan      = [1 1];
      dimensions.RowSpan         = [rowIdx rowIdx];
      dimensions.ColSpan         = [2 2];
      complexityLbl.RowSpan      = [rowIdx rowIdx];
      complexityLbl.ColSpan      = [3 3];
      complexity.Type             = 'combobox';
      complexity.Entries          = set(h,'Complexity')';
      complexity.RowSpan          = [rowIdx rowIdx];
      complexity.ColSpan          = [4 4];
      
      dimsRow   = rowIdx+1;
      complxRow = rowIdx;
      rowIdx = rowIdx + 2;
      complexity.ColSpan          = [2 2];
      complexityLbl.ColSpan       = [1 1];
          
      dimensionsLbl.RowSpan      = [dimsRow dimsRow];
      dimensionsLbl.ColSpan      = [1 1];
      dimensions.RowSpan         = [dimsRow dimsRow];
      dimensions.ColSpan         = [2 2];        
          
      % Dimensions mode
      dimensionsModeLbl.Name         = DAStudio.message('Simulink:dialog:DataDimensionsModePrompt');
      dimensionsModeLbl.Type         = 'text'; 
      dimensionsModeLbl.RowSpan      = [dimsRow dimsRow];
      dimensionsModeLbl.ColSpan      = [3 3];
      dimensionsModeLbl.Tag          = 'DimensionsModeLbl'; 
      
      dimensionsMode.Name            = dimensionsModeLbl.Name;
      dimensionsMode.HideName        = 1;
      dimensionsMode.Type            = 'combobox';
      dimensionsMode.Entries         = set(h,'DimensionsMode')';
      dimensionsMode.Source          = h;
      dimensionsMode.ObjectProperty  = 'DimensionsMode';
      dimensionsMode.RowSpan         = [dimsRow dimsRow];
      dimensionsMode.ColSpan         = [4 4];
      dimensionsMode.Tag             = 'DimensionsMode';
      dimensionsMode.ToolTip         = DAStudio.message('Simulink:dialog:DataDimensionsModeToolTip');
      complexityLbl.RowSpan       = [complxRow complxRow];
      complexity.RowSpan          = [complxRow complxRow];
      
      % Signal only widgets         
      
      % Sample time
      sampleTimeLbl.Name         = DAStudio.message('Simulink:dialog:SignalSampleTimePrompt');
      sampleTimeLbl.Type         = 'text'; 
      sampleTimeLbl.RowSpan      = [rowIdx rowIdx];
      sampleTimeLbl.ColSpan      = [1 1];
      sampleTimeLbl.Tag          = 'SampleTimeLbl'; 
      
      sampleTime.Name            = sampleTimeLbl.Name;
      sampleTime.HideName        = 1;
      sampleTime.Type            = 'edit';
      sampleTime.RowSpan         = [rowIdx rowIdx];
      sampleTime.ColSpan         = [2 2];
      sampleTime.Source          = h;
      sampleTime.ObjectProperty  = 'SampleTime';
      sampleTime.Tag             = 'SampleTime';
      sampleTime.ToolTip         = DAStudio.message('Simulink:dialog:SignalSampleTimeToolTip');
      
      % Sample mode
      sampleModeLbl.Name         = DAStudio.message('Simulink:dialog:SignalSampleModePrompt');
      sampleModeLbl.Type         = 'text'; 
      sampleModeLbl.RowSpan      = [rowIdx rowIdx];
      sampleModeLbl.ColSpan      = [3 3];
      sampleModeLbl.Tag          = 'SampleModeLbl'; 
      
      sampleMode.Name            = sampleModeLbl.Name;
      sampleMode.HideName        = 1;
      sampleMode.Type            = 'combobox';
      sampleMode.Entries         = set(h,'SamplingMode')';
      sampleMode.Source          = h;
      sampleMode.ObjectProperty  = 'SamplingMode';
      sampleMode.RowSpan         = [rowIdx rowIdx];
      sampleMode.ColSpan         = [4 4];
      sampleMode.Tag             = 'SampleMode';
      sampleMode.ToolTip         = DAStudio.message('Simulink:dialog:SignalSampleModeToolTip');
      
      rowIdx = rowIdx + 1;
      
      % Min and Max widgets
      minimumLbl.RowSpan          = [rowIdx rowIdx];
      minimumLbl.ColSpan          = [1 1];
      minimum.RowSpan             = [rowIdx rowIdx];
      minimum.ColSpan             = [2 2];
      maximumLbl.RowSpan          = [rowIdx rowIdx];
      maximumLbl.ColSpan          = [3 3];
      maximum.RowSpan             = [rowIdx rowIdx];
      maximum.ColSpan             = [4 4];
      rowIdx = rowIdx + 1;
      
      
      % Units widgets
      unitsLbl.RowSpan            = [rowIdx rowIdx];
      unitsLbl.ColSpan            = [3 3];
      units.RowSpan               = [rowIdx rowIdx];
      units.ColSpan               = [4 4]; 
      
      % InitialValue widgets
      initialValueLbl.Name       = DAStudio.message('Simulink:dialog:SignalInitialValuePrompt');
      initialValueLbl.Type       = 'text';
      initialValueLbl.RowSpan    = [rowIdx rowIdx];
      initialValueLbl.ColSpan    = [1 1];
      initialValueLbl.Tag        = 'InitialValueLbl';
      
      initialValue.Name          = initialValueLbl.Name;
      initialValue.HideName      = 1;
      initialValue.Type          = 'edit';
      initialValue.RowSpan       = [rowIdx rowIdx];
      initialValue.ColSpan       = [2 2];
      initialValue.Source        = h;
      initialValue.ObjectProperty= 'InitialValue';
      initialValue.ToolTip       = DAStudio.message('Simulink:dialog:SignalInitialValueToolTip');
      
      pnlObj.LayoutGrid           = [rowIdx 4];
      pnlObj.ColStretch           = [0 1 0 1]; 
      pnlObj.Items      = {dataTypeGroup, ...
                          complexityLbl, complexity,...
                          dimensionsLbl, dimensions,...
                          dimensionsModeLbl, dimensionsMode,...                            
                          sampleTimeLbl, sampleTime, ...
                          sampleModeLbl, sampleMode,...
                          minimumLbl, minimum, ...
                          maximumLbl, maximum, ...
                          initialValueLbl, initialValue, ...                          
                          unitsLbl, units};
  end

  %-------------------------------------------------------------------------
  % Row Two contains:
  % - Groupbox with code generation options 
  %-------------------------------------------------------------------------
  grpCodeGen.Items = {};
  rtwInfo = h.RTWInfo;
  hRTWInfoClass = classhandle(rtwInfo);
  storageClass = get(rtwInfo, 'StorageClass');
  props = get(hRTWInfoClass, 'Properties');
  numItems = 1;

  % StorageClass
  wid                 = [];
  wid.RowSpan         = [numItems numItems];
  wid.ColSpan         = [1 2];
  wid.Source          = h;
  wid.ObjectProperty  = 'StorageClass';
  wid.Entries         = getPropAllowedValues(h, 'StorageClass')';
  wid.Tag             = 'StorageClass';
  wid.Type            = 'combobox';
  wid.Name            = DAStudio.message('Simulink:dialog:DataStorageClassPrompt');
  wid.Source          = h;
  wid.Mode            = true;
  wid.DialogRefresh   = true;
  wid.MatlabMethod    = 'dataddg_cb';
  wid.MatlabArgs      = {0, 'refresh_me_cb', h};
  wid.ToolTip         = DAStudio.message('Simulink:dialog:DataStorageClassToolTip1');

  if isParameter
    wid.ToolTip = DAStudio.message('Simulink:dialog:DataStorageClassToolTip2');
  end
  
  grpCodeGen.Items{numItems} = wid;
  numItems = numItems+1;
  
  %
  % Add group for CustomAttributes (if necessary)
  %
  if (strcmp(storageClass, 'Custom'))
    % Now add the Custom Attributes group
    csAttribsProp = findprop(hRTWInfoClass, 'CustomAttributes');
    wid = populate_widget_from_object_property(rtwInfo, csAttribsProp, h);
    wid.Name = DAStudio.message('Simulink:dialog:DataCustomAttributesPrompt');

    % Add the StorageClass property
    wid.RowSpan = [numItems numItems];
    wid.ColSpan = [1 2];

    if (isfield(wid, 'Items') && ~isempty(wid.Items))
      wid.Items = align_names(wid.Items);
      wid.LayoutGrid = [length(wid.Items) 2];

     % if CSC is GetSet, translate their Get/Set function Prompts
      if ( strcmp(rtwInfo.CustomStorageClass, 'GetSet') ) 
          item_num = length(wid.Items);
          for k=1:item_num
              if (strcmp(wid.Items{k}.Name, 'Get function:')==true)
                  wid.Items{k}.Name = DAStudio.message('Simulink:dialog:DataCustomAttributesGetFunctionPrompt');
                  wid.Items{k}.Tag = wid.Items{k}.Name;
              elseif (strcmp(wid.Items{k}.Name, 'Set function:')==true)
                  wid.Items{k}.Name = DAStudio.message('Simulink:dialog:DataCustomAttributesSetFunctionPrompt');
                  wid.Items{k}.Tag = wid.Items{k}.Name;
              end
          end
      end

      grpCodeGen.Items{numItems} = wid;
      numItems = numItems+1;
    end
  end
    
  %
  % Add all the other RTWInfo properties
  %
  for i = 1:length(props)
    % Properties to skip.
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

    wid = populate_widget_from_object_property(rtwInfo, props(i), h);
    if (strcmp(wid.Type,'unknown') == 1)
      continue;
    end;

    % Add a tooltip if this widget is the "Alias" property.
    if strcmp(props(i).Name, 'Alias')
      wid.ToolTip = DAStudio.message('Simulink:dialog:DataAliasToolTip');
    end

    wid.MatlabMethod = 'dataddg_cb';
    wid.MatlabArgs = {0, 'refresh_me_cb', h};
    wid.RowSpan = [numItems numItems];
    wid.ColSpan = [1 2];

    % If you are not going to show this because type in unknown
    % issue a warning here
    grpCodeGen.Items{numItems} = wid;
    numItems = numItems+1;
  end

  grpCodeGen.Items      = align_names(grpCodeGen.Items);
  grpCodeGen.LayoutGrid = [numItems 2];

  grpCodeGen.Name       = DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
  grpCodeGen.Type       = 'group';
  grpCodeGen.RowSpan    = [2 2];
  grpCodeGen.ColSpan    = [1 2];
  grpCodeGen.Source     = h.RTWInfo;
  grpCodeGen.Tag        = 'GrpCodeGen';


  %-------------------------------------------------------------------------
  %                     LoggingInfo widgets 
  %
  %   Only for signals. For parameters, it is just an empty panel.
  %-------------------------------------------------------------------------
  if isParam || ~slfeature('ShowLoggingInfoOnSigObj')
      grpLoggingInfo.Items = {};
      grpLoggingInfo.Type = 'panel';
      grpLoggingInfo.LayoutGrid = [1 1];
  else
      grpLoggingInfo = getLoggingInfoPanel(h.LoggingInfo);
      grpLoggingInfo.Type = 'group';
      grpLoggingInfo.Name = DAStudio.message('Simulink:dialog:SigpropGrpLogging');
  end
  grpLoggingInfo.Tag = 'GrpLoggingInfo';
  grpLoggingInfo.RowSpan = [3 3];
  grpLoggingInfo.ColSpan = [1 2];

  %-------------------------------------------------------------------------
  %                     Generic wrapup widgets
  %-------------------------------------------------------------------------
  % description widget
  description.Name           = DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
  description.Type           = 'editarea';
  description.RowSpan        = [4 4];
  description.ColSpan        = [1 2];
  description.Source         = h;
  description.ObjectProperty = 'Description';
  description.Tag 	     = 'Description';

  %-------------------------------------------------------------------------
  % The dialog items cell array will consist of either:
  % - A tab container with two tabs (tab1, tab2)
  %    - The first tab will contain Signal/Parameter widgets, codegen widgets,
  %      description and document link widgets
  %    - The second tab will contain additional parameters not in the
  %       Signal/Parameter objects
  %                         -OR-
  % - Just the items listed for tab1 above.   
  %-------------------------------------------------------------------------

  %-------------------------------------------------------------------------
  % tab1 contains:
  % - Panel of Signal/Parameter widgets
  % - Code Generation groupbox
  % - Description editarea
  % - Document link and label
  %-------------------------------------------------------------------------
  tab1.Name = DAStudio.message('Simulink:dialog:DataTab1Prompt');
  tab1.LayoutGrid = [4 2];
  tab1.RowStretch = [0 0 0 1];
  tab1.ColStretch = [0 1];
  tab1.Source = h;
  tab1.Items = {pnlObj,...
                grpCodeGen,...
                grpLoggingInfo,...
                description}; 
  tab1.Tag = 'TabOne';
  
  %-----------------------------------------------------------------------
  % tab2 contains:
  %  - Additional properties groupbox
  %  - spacer widget to take up all remaining space
  %-----------------------------------------------------------------------

  % Create a groupbox to hold all properties that do no exist in the 
  % basic Simulink Signal or Simulink Parameter object

  grpAdditional.Name       = DAStudio.message('Simulink:dialog:DataAdditionalPropsPrompt');
  grpAdditional.Type       = 'panel';
  grpAdditional.RowSpan    = [1 1];
  grpAdditional.ColSpan    = [1 1];
  grpAdditional.Tag        = strcat('sfCoderoptsdlg_', grpAdditional.Name);
  grpAdditional.Items      = {};
  grpAdditional.Tag        = 'GrpAdditional';
  
  % populate the items list for grpAdditional
  props = find_reduced_set_of_properties(h);
  numItems = 1;
  for i = 1:length(props)
    if (~is_property_visible(props(i)))
      continue;
    end
    type2 = get_widget_type_from_property(h, props(i));
    % If the type is unknown do not include this widget in this group
    if (strcmp(type2,'unknown') == 1)
      continue;
    end;

    wid = populate_widget_based_on_property(h, props(i));
    wid.RowSpan = [numItems numItems];
    wid.ColSpan = [1 2];
    grpAdditional.Items{numItems}    = wid;
    numItems = numItems+1;
  end
  grpAdditional.LayoutGrid = [numItems 2];
  grpAdditional.Items = align_names(grpAdditional.Items);
  
  spacer.Type = 'panel';
  spacer.RowSpan = [2 2];
  spacer.ColSpan = [1 1];
  spacer.Tag =	'Spacer';
  
  tab2.Name = DAStudio.message('Simulink:dialog:DataTab2Prompt');
  tab2.Items = {grpAdditional, spacer};
  tab2.LayoutGrid = [2 1];
  tab2.RowStretch = [0 1];
  tab2.Tag = 'TabTwo';
    
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgOrPanel = [];
  if ~isRtnPanel
      if (strcmp(type,'signal') == 1 || strcmp(type, 'data') == 1)
        dlgOrPanel.DialogTitle = [h.getFullName, ': ', name];
      else
        dlgOrPanel.DialogTitle = ['Data properties:', name];
      end
    
      % Determine whether to create tab container based on whether grpAdditional has
      % any items to show
      noGrpItems = length(grpAdditional.Items);
      if (noGrpItems > 0)    
        % Create the tab container
        tabcont.Type = 'tab';
        tabcont.Tabs = {tab1 tab2};  
        tabcont.Tag = 'Tabcont';
        dlgOrPanel.Items = {tabcont};
      else
        dlgOrPanel.Items      = tab1.Items;
        dlgOrPanel.LayoutGrid = tab1.LayoutGrid;
        dlgOrPanel.RowStretch = tab1.RowStretch;
        dlgOrPanel.ColStretch = tab1.ColStretch;
      end;
    
      % Do the rest of assignments for this dialog
      dlgOrPanel.SmartApply = 0;
      dlgOrPanel.PreApplyCallback = 'dataddg_cb';
      dlgOrPanel.PreApplyArgs     = {'%dialog', 'preapply_cb'};
      dlgOrPanel.MinimalApply = true;
      dlgOrPanel.HelpMethod = 'helpview';
      dlgOrPanel.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], helpTopicKey};
    
  %-----------------------------------------------------------------------
  % Or assemble contents as a panel
  %-----------------------------------------------------------------------  
  else 
      dlgOrPanel.Type = 'panel';

      
      % Determine whether to create tab container based on whether grpAdditional has
      % any items to show
      noGrpItems = length(grpAdditional.Items);
      if (noGrpItems > 0)    
        % Create the tab container
        tabcont.Type = 'tab';
        tabcont.Tabs = {tab1 tab2};  
        tabcont.Tag = 'Tabcont';
        dlgOrPanel.Items = {tabcont};
      else
        dlgOrPanel.Items      = tab1.Items;
        dlgOrPanel.LayoutGrid = tab1.LayoutGrid;
        dlgOrPanel.RowStretch = tab1.RowStretch;
        dlgOrPanel.ColStretch = tab1.ColStretch;
      end;
  end
end

%-------------------------- End of main function ----------------------------

function wid = populate_widget_based_on_property(h, prop)
  wid = populate_widget_from_object_property(h, prop, h);
end

%-----------------------------------------------------------------------------
function props = find_reduced_set_of_properties(h)

  if ( isa(h, 'Simulink.Parameter'))
    basicObj = Simulink.Parameter;
  else
    basicObj = Simulink.Signal;
  end;

  basicProps = get(classhandle(basicObj), 'Properties');
  advancedProps =  get(classhandle(h), 'Properties');

  % If length of the advanced and basic props
  % are the same simply return empty
  if (length(basicProps) == length(advancedProps))
    props = [];
    return;
  end;

  % Here try to find a pruned list of properties
  j = 1;
  for i = 1:length(advancedProps)
    % Only append to the list if not a basic Property of the
    % simulink Parameter (basic object)
    if (is_basic_property(h, advancedProps(i)) == 0 )
      props(j) = advancedProps(i); %#ok
      j = j+1;
    end;
  end
end

%-------------------------------------------------------------------------------
function result = is_property_visible(property)
  result = 0;
  try
    accessFlags = get(property, 'AccessFlags');
    if (strcmp(property.Visible,'on') && ...
        strcmp(accessFlags.PublicGet,'on'))
      result = 1;
    end
  catch e %#ok
    % Current error is ignored
    disp(DAStudio.message('Simulink:dialog:NothingToDoPropNotVisbl'))      
  end;
end

%-------------------------------------------------------------------------------
function result = is_basic_property(h, property)
  if ( isa(h, 'Simulink.Parameter'))
    basicObj = Simulink.Parameter;
  else
    basicObj = Simulink.Signal;
  end
  basicProps = get(classhandle(basicObj), 'Properties');

  result = 0;
  for i = 1:length(basicProps)
    if (strcmp(basicProps(i).Name, property.Name))
      result = 1;
      break;
    end;
  end
end

% EOF
