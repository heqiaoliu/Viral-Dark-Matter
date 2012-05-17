function handleButtons(this,buttonStr)
%HANDLEBUTTONS Handle buttons in MessageLog dialog.

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/01/25 22:48:01 $

switch buttonStr
    case 'summary'
        % line in summary listbox selected
        % Copy detail of selected item into property cache,
        % then refresh dialog at exit
        this.SelectedSummary = this.Dialog.getWidgetValue('summary');
        cacheDialogDetail(this);
        
    case 'type'
        
        % Update the selected type based on the current value.
        this.SelectedType    = this.Dialog.getWidgetValue('type');
        
        %Reset the Selected Summary back to the first item.
        this.SelectedSummary = 0;
        
        % Update the Details text field.
        cacheDialogDetail(this);
    case 'category'
        
        % Update the selected category based on the current value.
        this.SelectedCategory = this.Dialog.getWidgetValue('category');
        
        %Reset the Selected Summary back to the first item.
        this.SelectedSummary  = 0;
        
        % Update the Details text field.
        cacheDialogDetail(this);
        
    case 'delete'
        % Delete log entries based on type and category
        [mType,mCat] = getDialogTypeCat(this);
        removeTypeCat(this,mType,mCat);
        
        % Deleting selected entries implies current message
        % must also now be gone
        this.cache_SelectedDetail = '';

    otherwise
        delete(d);  % close dialog
end
refresh(this.dialog); % force dialog to update


% function selectFirstItemInSummaryList(this)
% %select the first item in the summary widget after the dialog has been 
% %opened
% this.setWidgetValue('summary', 0);


% [EOF]
