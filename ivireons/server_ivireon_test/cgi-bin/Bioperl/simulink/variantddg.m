function dlgstruct = variantddg(h, name)
% VARIANTDDG Dynamic dialog for Simulink variant objects.

% To lauch this dialog in MATLAB, use:
%    >> a = Simulink.Variant;
%    >> DAStudio.Dialog(a);    

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $

%% Add a description pane
descTxt.Name     = DAStudio.message('Simulink:dialog:VariantObject');                    
descTxt.Type     = 'text';
descTxt.WordWrap = true;

descGrp.Name     = 'Simulink.Variant';
descGrp.Type     = 'group';
descGrp.Items    = {descTxt};
descGrp.RowSpan  = [1 1];
descGrp.ColSpan  = [1 2];

%-----------------------------------------------------------------------
% Row contains:
% - Condition label widget
% - Condition edit field widget
%-----------------------------------------------------------------------
conditionLabel.Name      = DAStudio.message('Simulink:dialog:SLVariantCondition');
conditionLabel.Type      = 'text';
conditionLabel.RowSpan   = [2 2];
conditionLabel.ColSpan   = [1 1];
conditionLabel.Tag       = 'ConditionLabel';

condition.Name           = '';
condition.RowSpan        = [2 2];
condition.ColSpan        = [2 2];
condition.Type           = 'edit';
condition.Tag            = 'Condition_tag';
condition.ObjectProperty = 'Condition';

spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [3 3];
spacer.ColSpan = [1 2];

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------  
dlgstruct.DialogTitle = [class(h), ': ', name];
dlgstruct.Items = {descGrp, conditionLabel, condition, spacer};
dlgstruct.LayoutGrid = [3 2];
dlgstruct.HelpMethod = 'helpview';
dlgstruct.HelpArgs   = {[docroot '/mapfiles/simulink.map'], 'simulink_variant_type'};
dlgstruct.RowStretch = [0 0 1];
dlgstruct.ColStretch = [0 1];
dlgstruct.CloseCallback = ['subsysVariantsddg_cb(''UpdateObject'',' name ', ''' name ''');' ...
                   'mdlrefddg_cb(''UpdateObject'',' name ', ''' name ''');'];

