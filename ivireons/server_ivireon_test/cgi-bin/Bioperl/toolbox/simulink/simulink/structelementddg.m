function dlgstruct = structelementddg(h, name, isBus)
% STRUCTELEMENTDDG Dynamic dialog for Simulink StructElement/BusElement objects.

% To launch dialog for StructElement in MATLAB, use:
%    >> a = Simulink.StructElement;
%    >> DAStudio.Dialog(a);
% To launch dialog for BusElement in MATLAB, use:
%    >> a = Simulink.BusElement;    
%    >> DAStudio.Dialog(a);

% Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.15 $ $Date: 2010/04/21 21:59:34 $

   if (nargin == 2)
     isBus = false;
   end
    
   rowIdx = 1; 
   nameLbl.Name = DAStudio.message('Simulink:dialog:StructelementNameLblName');
   nameLbl.Type = 'text';
   nameLbl.RowSpan = [rowIdx rowIdx];
   nameLbl.ColSpan = [1 1];
   nameLbl.Tag = 'NameLbl';
   
   nameVal.Name = nameLbl.Name;
   nameVal.HideName = 1;
   nameVal.RowSpan = [rowIdx rowIdx];
   nameVal.ColSpan = [2 4];
   nameVal.Type = 'edit';
   nameVal.Tag = 'name_tag';
   nameVal.ObjectProperty = 'Name';
   
   rowIdx = rowIdx + 1;

    % Unified DataType

    % Add scaling modes/ signed unsigned modes / built-in types
    dataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dataTypeItems.signModes    = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    
    % Use allowed values as built-ins but remove "fixdt..." items and explicit
    % data type items (e.g. "Enum: <class name>" from the end of the list
    allowedVals = h.getPropAllowedValues('DataType');
    for idx = length(allowedVals):-1:1
        if ~isempty(findstr('fixdt', allowedVals{idx})) || ...
           ~isempty(findstr(':', allowedVals{idx}))
            % Remove this item
            allowedVals(idx) = [];
        else
            % All of the remaining types are built-ins
            break;
        end
    end
    dataTypeItems.builtinTypes = allowedVals;

    % Simulink data supports enumerate data type and bus data type
    dataTypeItems.supportsEnumType = true;
    dataTypeItems.supportsBusType = true;
    
    % Get Widget for Unified dataType
    dataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(h, ...
                                                                 'DataType', ...
                                                                 DAStudio.message('Simulink:dialog:StructelementDatatypeLblName'), ...
                                                                 'datatypetag', ...
                                                                 h.DataType, ...
                                                                 dataTypeItems, ...
                                                                 false);
       dataTypeGroup.RowSpan = [rowIdx rowIdx];
       dataTypeGroup.ColSpan = [1 4]; 

   rowIdx = rowIdx + 1;
   
   % Dimensions
   dimLbl.Name = DAStudio.message('Simulink:dialog:StructelementDimLblName');
   dimLbl.Type = 'text';
   dimLbl.RowSpan = [rowIdx rowIdx];
   dimLbl.ColSpan = [1 1];
   dimLbl.Tag = 'DimLbl';
   
   dim.Name = dimLbl.Name;
   dim.HideName = 1;
   dim.RowSpan = [rowIdx rowIdx];
   dim.ColSpan = [2 2];
   dim.Type = 'edit';
   dim.Tag = 'dim_tag';
   dim.ObjectProperty = 'Dimensions';
   
   % Complexity
   complexLbl.Name = DAStudio.message('Simulink:dialog:StructelementComplexLblName');
   complexLbl.Type = 'text';
   complexLbl.RowSpan = [rowIdx rowIdx];
   complexLbl.ColSpan = [3 3];
   complexLbl.Tag = 'ComplexLbl';
   
   complex.Name = complexLbl.Name;
   complex.HideName = 1;
   complex.RowSpan = [rowIdx rowIdx];
   complex.ColSpan = [4 4];
   complex.Type = 'combobox';
   complex.Tag = 'complex_tag';
   complex.Entries = set(h, 'Complexity')';
   complex.ObjectProperty = 'Complexity';
   complex.Mode = 1;
   complex.DialogRefresh = 1;

   rowIdx = rowIdx + 1;   
   
   % Check if DataType is Bus Element
   if(isBus)
       % Get Sample Time and Mode widgets
       [extraBusWidgets rowIdx] = buselementwidgets(h, rowIdx);
   end
   
   blankWidget.Name = '';
   blankWidget.Type = 'text';
   blankWidget.RowSpan = [rowIdx rowIdx];
   blankWidget.ColSpan = [1 4];
   blankWidget.Tag = 'blankWidgetTag'; 
   
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = [class(h), ': ', name];
  
  dlgstruct.Items = {nameLbl, nameVal};

  dlgstruct.Items{end+1} = dataTypeGroup;
  
  dlgstruct.Items = [dlgstruct.Items, {dimLbl, dim, complexLbl, complex}];
  
  if isBus
      dlgstruct.Items = [dlgstruct.Items, extraBusWidgets];
  end
  
  dlgstruct.Items{end+1} = blankWidget;

  dlgstruct.LayoutGrid = [rowIdx 4];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], 'simulink_struct_element'};
  dlgstruct.ColStretch = [0 1 0 1];
  dlgstruct.RowStretch = [zeros(1, (rowIdx-1)) 1];

% end of main function

function [extraBusWidget, rowIdx] = buselementwidgets(h, rowIdx)
% Dynamic dialog Sample Time and Mode for Simulink BusElement type objects.

   samptimeLbl.Name = DAStudio.message('Simulink:dialog:BuselementSamptimeLblName');
   samptimeLbl.Type = 'text';
   samptimeLbl.RowSpan = [rowIdx rowIdx];
   samptimeLbl.ColSpan = [1 1];
   samptimeLbl.Tag = 'SamptimeLbl';
   
   samptime.Name = samptimeLbl.Name;
   samptime.HideName = 1;
   samptime.RowSpan = [rowIdx rowIdx];
   samptime.ColSpan = [2 2];
   samptime.Type = 'edit';
   samptime.Tag = 'samptime_tag';
   samptime.ObjectProperty = 'SampleTime';
   
   sampmodeLbl.Name = DAStudio.message('Simulink:dialog:BuselementSampmodeLblName');
   sampmodeLbl.Type = 'text';
   sampmodeLbl.RowSpan = [rowIdx rowIdx];
   sampmodeLbl.ColSpan = [3 3];
   sampmodeLbl.Tag = 'SampmodeLbl';

   sampmode.Name = sampmodeLbl.Name;
   sampmode.HideName = 1;
   sampmode.RowSpan = [rowIdx rowIdx];
   sampmode.ColSpan = [4 4];
   sampmode.Type = 'combobox';
   sampmode.Tag = 'sampmode_tag';
   sampmode.Entries = set(h, 'SamplingMode')';
   sampmode.ObjectProperty = 'SamplingMode';
   sampmode.Mode = 1;
   sampmode.DialogRefresh = 1;

   rowIdx = rowIdx + 1;
   
   extraBusWidget = {samptimeLbl, samptime, sampmodeLbl, sampmode};  
   
   % Dimensions Mode
   dimsmodeLbl.Name = DAStudio.message('Simulink:dialog:BuselementDimsmodeLblName');
   dimsmodeLbl.Type = 'text';
   dimsmodeLbl.RowSpan = [rowIdx rowIdx];
   dimsmodeLbl.ColSpan = [1 1];
   dimsmodeLbl.Tag = 'DimsmodeLbl';
   
   dimsmode.Name = '';
   dimsmode.RowSpan = [rowIdx rowIdx];
   dimsmode.ColSpan = [2 2];
   dimsmode.Type = 'combobox';
   dimsmode.Tag = 'dimsmode_tag';
   dimsmode.Entries = set(h, 'DimensionsMode')';
   dimsmode.ObjectProperty = 'DimensionsMode';
   dimsmode.Mode = 1;
   dimsmode.DialogRefresh = 1;
       
   extraBusWidget = {extraBusWidget{:}, dimsmodeLbl, dimsmode};  
   
   rowIdx = rowIdx + 1;
   % end of buselementwidgets
   
 
