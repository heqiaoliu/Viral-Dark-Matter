function dlgstruct = busddg(h, name)
% BUSDDG Dynamic dialog for Simulink Bus type objects.

% To lauch this dialog in MATLAB, use:
%    >> a = Simulink.Bus;
%    >> a.Elements = Simulink.BusElement;
%    >> DAStudio.Dialog(a);

% Copyright 2003-2008 The MathWorks, Inc.
% $Revision: 1.1.6.14 $
  
    %-----------------------------------------------------------------------
    % First Row contains:
    % - elements groupbox with
    % - elements table widget
    %-----------------------------------------------------------------------  

    tableData = {};
    if ~isempty(h.Elements)
        for i=1:length(h.Elements)
            val = h.Elements(i);
            tableData{i, 1} = val.Name; %#ok

            dim = mat2str(val.Dimensions);
            tableData{i, 2} = val.DataType; %#ok
            tableData{i, 3} = val.Complexity; %#ok
            tableData{i, 4} = dim; %#ok

            tableData{i, 5} = val.DimensionsMode; %#ok
            tableData{i, 6} = val.SamplingMode; %#ok
            nextIdx = 7;


            if ~isscalar(val.SampleTime)
                sam = sprintf('[%d %d]', val.SampleTime(1), val.SampleTime(2));
            else
                sam = num2str(val.SampleTime);
            end
            tableData{i, nextIdx} = sam; %#ok
        end
    end

    bustable.Type = 'table';
    bustable.Size = size(tableData);
    bustable.Grid = 0;
    bustable.HeaderVisibility = [0 1];
    bustable.ColHeader = {DAStudio.message('Simulink:dialog:BusBustableColHeaderName'), ...
                        DAStudio.message('Simulink:dialog:BusBustableColHeaderDataBusType'), ...
                        DAStudio.message('Simulink:dialog:BusBustableColHeaderComplexity'), ...
                        DAStudio.message('Simulink:dialog:BusBustableColHeaderDimension'), ...
                        DAStudio.message('Simulink:dialog:BusBustableColHeaderDimensionsMode'), ...
                        DAStudio.message('Simulink:dialog:BusBustableColHeaderSamplingMode'), ...
                        DAStudio.message('Simulink:dialog:BusBustableColHeaderSampleTime')};
    bustable.Data = tableData;
    bustable.Tag = 'Bustable';
    
    %DDG Table widget cannot listen to properties. 
    %Hence, introduce an invisible edit widget and associate it with the 
    %'Elements' property.
    bustableHidden.Name = '';
    bustableHidden.Visible = false;
    bustableHidden.Type = 'edit';
    bustableHidden.Tag = 'elementsHidden_tag';
    bustableHidden.ObjectProperty = 'Elements';

    elementsgrp.Name = DAStudio.message('Simulink:dialog:BusElementsgrpName');
    elementsgrp.RowSpan = [1 1];
    elementsgrp.ColSpan = [1 3];
    elementsgrp.Type = 'group';
    elementsgrp.Flat = 1;
    elementsgrp.Items = {bustable, bustableHidden};
    elementsgrp.Tag = 'BusElementsGrp';
     
  
  %-----------------------------------------------------------------------
  % Second  Row contains:
  % - headerFile label widget
  % - headerFile edit field widget
  %-----------------------------------------------------------------------
  headerFileLbl.Name = DAStudio.message('Simulink:dialog:BusHeaderFileLblName');
  headerFileLbl.Type = 'text';
  headerFileLbl.RowSpan = [2 2];
  headerFileLbl.ColSpan = [1 1];
  headerFileLbl.Tag = 'HeaderFileLbl';
  
  headerFile.Name = '';
  headerFile.RowSpan = [2 2];
  headerFile.ColSpan = [2 3];
  headerFile.Type = 'edit';
  headerFile.Tag = 'headerFile_tag';
  headerFile.ObjectProperty = 'HeaderFile';
  
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - Description editarea widget
  %----------------------------------------------------------------------- 
  description.Name           = DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
  description.Type           = 'editarea';
  description.RowSpan        = [3 3];
  description.ColSpan        = [1 3];
  description.Tag            = 'description_tag';
  description.ObjectProperty = 'Description';  
  
  %-----------------------------------------------------------------------
  % Fourth Row contains:
  % - Launch buseditor button
  %----------------------------------------------------------------------- 
  editorbtn.Name = DAStudio.message('Simulink:dialog:BusEditorbtnName');
  editorbtn.Type = 'pushbutton';
  editorbtn.MatlabMethod = 'buseditor';
  editorbtn.MatlabArgs = {'Create', name};
  editorbtn.RowSpan = [4 4];
  editorbtn.ColSpan = [3 3];
  editorbtn.Tag = 'Editorbtn';
   
  %-----------------------------------------------------------------------
  
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = [class(h), ': ', name];
  dlgstruct.LayoutGrid  = [4 3];
  dlgstruct.RowStretch  = [0 0 1 0];
  dlgstruct.ColStretch  = [0 1 0];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], 'simulink_bus'};

  dlgstruct.Items = {elementsgrp, ...
                       headerFileLbl, headerFile, ...
                       description, editorbtn};
                   
