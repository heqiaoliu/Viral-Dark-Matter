function dlgstruct = numerictypeddg(h, name)
% NUMERICTYPEDDG Dynamic dialog for Simulink numeric type objects.

% To launch this dialog in MATLAB, use:
%    >> a = Simulink.NumericType;
%    >> DAStudio.Dialog(a);

% Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.15.2.1 $ 

  %-----------------------------------------------------------------------
  % First Row contains:
  % - dataTypeMode label widget
  % - dataTypeMode combobox widget
  %----------------------------------------------------------------------- 
  dataTypeModeLbl.Name = DAStudio.message('Simulink:dialog:NumericTypeDataTypeModePrompt');
  dataTypeModeLbl.Type = 'text';
  dataTypeModeLbl.RowSpan = [1 1];
  dataTypeModeLbl.ColSpan = [1 1];
  dataTypeModeLbl.Tag = 'DataTypeModeLbl';
  
  dataTypeMode.Name = '';
  dataTypeMode.RowSpan = [1 1];
  dataTypeMode.ColSpan = [2 2];
  dataTypeMode.Tag = 'DataTypeMode';
  dataTypeMode.Type = 'combobox';
  dataTypeMode.Entries = set(h, 'DataTypeMode')';
  dataTypeMode.ObjectProperty = 'DataTypeMode';
  dataTypeMode.Mode = 1;
  dataTypeMode.DialogRefresh = 1;
  catVal = h.dataTypeMode;
  
  %-----------------------------------------------------------------------
  % Second Row contains:
  % - signedness label widget
  % - signedness combobox widget
  %----------------------------------------------------------------------- 
  signednessLbl.Name = DAStudio.message('Simulink:dialog:NumericTypeSignednessPrompt');
  signednessLbl.Type = 'text';
  signednessLbl.RowSpan = [2 2];
  signednessLbl.ColSpan = [1 1];
  signednessLbl.Tag = 'SignednessLbl';
  
  signedness.Name = '';
  signedness.RowSpan = [2 2];
  signedness.ColSpan = [2 2];
  signedness.Tag =  'Signedness';
  signedness.Type = 'combobox';
  signedness.Entries = set(h, 'Signedness')';
  signedness.ObjectProperty = 'Signedness';
  signedness.Mode = 1;
  signedness.DialogRefresh = 1;
  
  if isscaledtype(h)
    signednessLbl.Visible = 1;
    signedness.Visible = 1;
  else
    signednessLbl.Visible = 0;
    signedness.Visible = 0;
  end;
    
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - Word length label widget
  % - Word length edit field widget
  %----------------------------------------------------------------------- 
  wordLengthLbl.Name = DAStudio.message('Simulink:dialog:NumericTypeWordLengthPrompt');
  wordLengthLbl.Type = 'text';
  wordLengthLbl.RowSpan = [3 3];
  wordLengthLbl.ColSpan = [1 1];
  wordLengthLbl.Tag = 'WordLengthLbl';
  
  wordLength.Name = '';
  wordLength.RowSpan = [3 3];
  wordLength.ColSpan = [2 2];
  wordLength.Tag = 'WordLength';
  wordLength.Type = 'edit';
  wordLength.ObjectProperty = 'WordLengthString'; 
  wordLength.Mode = 1;
  if (strcmp(catVal, 'Double') || strcmp(catVal, 'Single') ||... 
      strcmp(catVal, 'Boolean'))
    wordLengthLbl.Visible = 0;
    wordLength.Visible    = 0;
  else
    wordLengthLbl.Visible = 1;
    wordLength.Visible    = 1;
  end;

  %-----------------------------------------------------------------------
  % Fourth Row contains:
  % - Fraction length label widget
  % - Fraction length edit field widget
  % (only visible for Fixed-point: Binary point scaling mode)
  %----------------------------------------------------------------------- 
  fracLenLbl.Name = DAStudio.message('Simulink:dialog:NumericTypeFractionLengthPrompt');
  fracLenLbl.Type = 'text';
  fracLenLbl.RowSpan = [4 4];
  fracLenLbl.ColSpan = [1 1];
  fracLenLbl.Tag = 'FracLenLbl';
  
  fracLen.Name = '';
  fracLen.RowSpan = [4 4];
  fracLen.ColSpan = [2 2];
  fracLen.Tag = 'FractionLength';
  fracLen.Type = 'edit';
  fracLen.ObjectProperty = 'FractionLengthString';
  fracLen.Mode = 1;
  fracLen.DialogRefresh = 1;
  if strcmp(catVal, 'Fixed-point: binary point scaling')
    fracLenLbl.Visible = 1;
    fracLen.Visible    = 1;
  else
    fracLenLbl.Visible = 0;
    fracLen.Visible    = 0;
  end
  
  %-----------------------------------------------------------------------
  % Fifth Row contains:
  % - Slope label widget
  % - Slope edit field widget
  %----------------------------------------------------------------------- 
  slopeLbl.Name = DAStudio.message('Simulink:dialog:NumericTypeSlopePrompt');
  slopeLbl.Type = 'text';
  slopeLbl.RowSpan = [5 5];
  slopeLbl.ColSpan = [1 1];
  slopeLbl.Tag = 'SlopeLbl';
  
  slope.Name = '';
  slope.RowSpan = [5 5];
  slope.ColSpan = [2 2];
  slope.Type = 'edit';
  slope.Tag = 'Slope';
  slope.ObjectProperty = 'SlopeString'; 
  slope.Mode = 1;
  slope.DialogRefresh = 1;
  if (strcmp(catVal, 'Fixed-point: slope and bias scaling'))
    slopeLbl.Visible = 1;
    slope.Visible    = 1;
  else
    slopeLbl.Visible = 0;
    slope.Visible    = 0;
  end;
  
  %-----------------------------------------------------------------------
  % Sixth Row contains:
  % - Bias label widget
  % - Bias edit field widget
  %----------------------------------------------------------------------- 
  biasLbl.Name = DAStudio.message('Simulink:dialog:NumericTypeBiasPrompt');
  biasLbl.Type = 'text';
  biasLbl.RowSpan = [6 6];
  biasLbl.ColSpan = [1 1];
  biasLbl.Tag = 'BiasLbl';
  
  bias.Name = '';
  bias.RowSpan = [6 6];
  bias.ColSpan = [2 2];
  bias.Type = 'edit';
  bias.Tag = 'Bias';
  bias.ObjectProperty = 'BiasString';
  bias.Mode = 1;
  if (strcmp(catVal, 'Fixed-point: slope and bias scaling'))
    biasLbl.Visible = 1;
    bias.Visible    = 1;
  else
    biasLbl.Visible = 0;
    bias.Visible    = 0;
  end;
  
  %-----------------------------------------------------------------------
  % Seventh Row contains:
  % - DTO property combo box widget
  %----------------------------------------------------------------------- 
  dataTypeOverrideLbl.Name = DAStudio.message('Simulink:dialog:NumericTypeDataTypeOverridePrompt');
  dataTypeOverrideLbl.Type = 'text';
  dataTypeOverrideLbl.RowSpan = [7 7];
  dataTypeOverrideLbl.ColSpan = [1 1];
  dataTypeOverrideLbl.Tag = 'DataTypeOverrideLbl';

  comboDataTypeOverride.Name = '';
  comboDataTypeOverride.RowSpan = [7 7];
  comboDataTypeOverride.ColSpan = [2 2];
  comboDataTypeOverride.Type = 'combobox';
  comboDataTypeOverride.Entries = set(h, 'DataTypeOverride')';
  comboDataTypeOverride.Tag = 'DataTypeOverride';
  comboDataTypeOverride.ObjectProperty = 'DataTypeOverride';

  %-----------------------------------------------------------------------
  % Eighth Row contains:
  % - IsAlias checkbox widget
  %----------------------------------------------------------------------- 
  isAlias.Name = DAStudio.message('Simulink:dialog:NumericTypeIsAliasPrompt');
  isAlias.RowSpan = [8 8];
  isAlias.ColSpan = [1 1];
  isAlias.Type = 'checkbox';
  isAlias.Tag = 'IsAlias';
  isAlias.ObjectProperty = 'IsAlias';
  
  %-----------------------------------------------------------------------
  % Ninth Row contains:
  % - HeaderFile label widget
  % - HeaderFile edit field widget
  %----------------------------------------------------------------------- 
  headerFileLbl.Name = DAStudio.message('Simulink:dialog:DataTypeHeaderFilePrompt');
  headerFileLbl.Type = 'text';
  headerFileLbl.RowSpan = [9 9];
  headerFileLbl.ColSpan = [1 1];
  headerFileLbl.Tag = 'HeaderFileLbl';
  
  headerFile.Name = '';
  headerFile.RowSpan = [9 9];
  headerFile.ColSpan = [2 2];
  headerFile.Type = 'edit';
  headerFile.Tag = 'HeaderFile';
  headerFile.ObjectProperty = 'HeaderFile';
  
  %-----------------------------------------------------------------------
  % Tenth Row contains:
  % - Description editarea widget
  %----------------------------------------------------------------------- 
  description.Name = DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
  description.Type = 'editarea';
  description.Tag = 'Description';
  description.RowSpan = [10 10];
  description.ColSpan = [1 2];
  description.ObjectProperty = 'Description';  
  
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = [class(h), ': ', name];
  dlgstruct.Items = {dataTypeModeLbl, dataTypeMode, ... 
                     signednessLbl, signedness, ...
                     wordLengthLbl, wordLength, ...
                     fracLenLbl, fracLen, ...
                     slopeLbl, slope, ...
                     biasLbl, bias, ...
                     dataTypeOverrideLbl, comboDataTypeOverride, ...
                     isAlias, ...
                     headerFileLbl, headerFile, ...
                     description};
  dlgstruct.LayoutGrid = [10 2];
  dlgstruct.RowStretch = [0 0 0 0 0 0 0 0 0 1];
  dlgstruct.ColStretch = [0 1];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], 'simulink_numeric_type'};
  
