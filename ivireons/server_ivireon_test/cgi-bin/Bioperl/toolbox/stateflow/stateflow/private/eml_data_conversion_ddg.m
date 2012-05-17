function G = eml_data_conversion_ddg(h,row,cols,inStateflow)

% Copyright 2005-2009 The MathWorks, Inc.

if inStateflow
    context = 'Stateflow';
    objectKind = message('Data');
    objectKinds = message('Datas');
    groupColSpan = cols;
else
    context = 'Simulink';
    objectKind = message('Signal');
    objectKinds = message('Signals');
    groupColSpan = [1 1];
end

fimathLessFisOn = fifeature('FimathLessFis');
grows = 1;

% TreatIntsAsFixpt
if ~inStateflow
    treatIntsAsFixptCheck.Name = message('TreatIntsAsFixptName');
    treatIntsAsFixptCheck.Type = 'combobox';
    % added xlatesafe for translation since Integer is a single common word
    treatIntsAsFixptCheck.Entries = {...
        'Fixed-point',...
        'Fixed-point & Integer' };
    %            ,...
    % These two options are removed in R2007b. 
    % We are yet not sure if this decision is final,
    % so I do not remove them from the code base completely.
    %            'Fixed-point & Floating-point',...
    %            'Fixed-point & Integer & Floating-point'};
    
    treatIntsAsFixptCheck.ObjectProperty = 'TreatAsFi';
    treatIntsAsFixptCheck.RowSpan = [grows grows];
    treatIntsAsFixptCheck.ColSpan = [1 1];
    grows = grows + 1;
end


% Fimath Edit Box
fimathLabel.Type = 'editarea';
fimathLabel.ObjectProperty = 'InputFimath';
fimathLabel.ToolTip = message('FimathToolTip');
fimathLabel.Visible = false;

if fimathLessFisOn
 % EML Default Fimath combox box
 emlDefaultFimath.Type = 'radiobutton';
 emlDefaultFimath.Name = '';
 emlDefaultFimath.RowSpan = [grows grows]; %[1 1];
 emlDefaultFimath.ColSpan = [1 2];
 emlDefaultFimath.Entries = {message('EMLFimathSameAsML'),message('EMLFimathSpecify')};%{'Same as MATLAB','Specify Other'};
 emlDefaultFimath.ToolTip = message('EMLFimathToolTip');%'Specify the embedded.fimath that will be used by fixed-point inputs and fis in the EML function.';
 emlDefaultFimath.ObjectProperty = 'EmlDefaultFimath';
 emlDefaultFimath.Mode = 1;
 emlDefaultFimath.DialogRefresh = 1;
 emlDefaultFimath.OrientHorizontal = 1;
 grows = grows + 1;

 
 % Read Only MATLAB Default Fimath Display box
 fimathLabelReadOnly.Type = 'editarea';
 fimathLabelReadOnly.RowSpan = [grows grows]; %[2 2]
 fimathLabelReadOnly.ColSpan = [1 2];
 fimathLabelReadOnly.Value = tostring(fimath);
 fimathLabelReadOnly.Enabled = false;
 grows = grows+1;
  
 % Writable Fimath Edit Area
 fimathLabel.RowSpan = [grows grows]; %[3 3]
 fimathLabel.ColSpan = [1 2];
 
 % Display FimathLabelReadOnly OR FimathLabel
 if strcmpi(h.EmlDefaultFimath,'Same as MATLAB Default')
     fimathLabel.Visible = false;
     fimathLabelReadOnly.Visible = true;
 else
     fimathLabelReadOnly.Visible = false; 
     fimathLabel.Visible = true;
 end
  
else
    % Default Fimath
    fimathLabel.Name = message('FimathLabel',objectKinds);
    fimathLabel.RowSpan = [grows grows];
    fimathLabel.ColSpan = [1 2];
    fimathLabel.Visible = true;
    grows = grows+1;
    
    % Default fimath for fis in the EML function
    fimathForFis.Type = 'combobox';
    fimathForFis.ObjectProperty = 'FimathForFiConstructors';
    fimathForFis.Name = message('FimathForFisName');
    fimathForFis.RowSpan = [grows grows];
    fimathForFis.ColSpan = [1 2];
    fimathForFis.Entries = {message('FimathForFisSameAs',objectKinds),...
        message('FimathForFisDefault')};
    fimathForFis.ToolTip = message('FimathForFisToolTip');
    grows = grows + 1;
    
end


if fimathLessFisOn
    G.Name = '';
    G.Type = 'panel';
else
    G.Type = 'group';
    G.Name = [context ' input ' objectKind ' properties'];
end
G.RowSpan = [row row];
G.ColSpan = groupColSpan;
G.ColStretch = [0 1];

if fimathLessFisOn
    % Create a group for the fimath widgets
    fimathGroup.Name = message('EMLBlockFimath');% 'EML Block Fimath';
    fimathGroup.Type = 'group';
    fimathGroup.RowSpan = [3 3];
    fimathGroup.ColSpan = groupColSpan;
    fimathGroup.LayoutGrid = [3 2];
    fimathGroup.ColStretch = [0 1];
    fimathGroup.Items = {emlDefaultFimath, fimathLabelReadOnly, fimathLabel};
    GItems = {fimathGroup}; 
else
    GItems = {fimathLabel, fimathForFis};
end

if inStateflow
    G.LayoutGrid = [grows 2];
    G.Items = GItems;
else
    G.LayoutGrid = [grows 2];
    G.Items = [GItems,treatIntsAsFixptCheck];
end

function s = message(id,varargin)

s = DAStudio.message(['Stateflow:dialog:EMLDataConversion' id],varargin{:});
