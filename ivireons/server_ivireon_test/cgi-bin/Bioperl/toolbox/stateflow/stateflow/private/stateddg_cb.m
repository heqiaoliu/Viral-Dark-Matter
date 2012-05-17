function varargout = stateddg_cb(dlg, action, varargin)

% Copyright 2005-2009 The MathWorks, Inc.

if ~isempty(dlg)
    h = dlg.getDialogSource;
end


switch action
    
    case 'doUseTextAsClickFcn'
        if (dlg.getWidgetValue('sfStatedlg_useTextAsClickFcn'))
            dlg.setUserData('sfStatedlg_clickFcnEdit', dlg.getWidgetValue('sfStatedlg_clickFcnEdit'));
            dlg.setWidgetValue('sfStatedlg_clickFcnEdit', dlg.getWidgetValue('sfStatedlg_Label:'));    
            dlg.setEnabled('sfStatedlg_clickFcnEdit', false);
        else
            dlg.setWidgetValue('sfStatedlg_clickFcnEdit', dlg.getUserData('sfStatedlg_clickFcnEdit'));
            dlg.setEnabled('sfStatedlg_clickFcnEdit', true);
        end
        
    case 'doApply'
        %G400057, Apply state label string before any other properties
        %applies. This is because "OutputStateActivity" is dependent on
        %state label string. So the order has to be ensured.
        hState = dlg.getSource;
        dlgLabelVal = dlg.getWidgetValue('sfStatedlg_Label:');
        isNoteBox = sf('get', hState.Id, '.isNoteBox');
        isCompState = sf('get', h.Id, '.simulink.isComponent');
        
        if(~isNoteBox && ~strcmp(hState.LabelString, dlgLabelVal))
            if isCompState
                hState.Name = dlgLabelVal;
            else
                hState.LabelString = dlgLabelVal;
            end
        end
        
        if isCompState
            subchart_man('applyBindings', hState.Id);
        end
        
        if (dlg.getWidgetValue('sfStatedlg_useTextAsClickFcn'))
            dlg.setWidgetValue('sfStatedlg_clickFcnEdit', dlg.getWidgetValue('sfStatedlg_Label:'));
        end
end

varargout{1} = 1;
varargout{2} = '';
