function dlg = getDialogSchema(this, ~)

%   Copyright 2010 The MathWorks, Inc.


dlg.DialogTitle = 'HTML Settings';

htmlOptions = cvi.ReportUtils.getOptionsTable;
[m, ~] = size(htmlOptions );
dlg.Items = {};
for idx = 1:m
    fieldName =  htmlOptions{idx,2};
    text =  htmlOptions{idx,1};
    chb = addCheckBox(this, fieldName, text);
    if isempty(dlg.Items)
        dlg.Items = {chb};
    else
        dlg.Items{end+1} = chb;
    end
end

dlg.PostApplyMethod  = 'postApply';
dlg.StandaloneButtonSet = {'Ok', 'Cancel'};

%===========================
function chb = addCheckBox(this, fieldName, text)

chb.Name = text;
chb.Type = 'checkbox';
chb.Source = this.m_callerSource;
chb.ObjectProperty = fieldName;
