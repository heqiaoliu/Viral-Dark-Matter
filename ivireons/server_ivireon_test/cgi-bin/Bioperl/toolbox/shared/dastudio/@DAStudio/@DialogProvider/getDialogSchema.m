function dlgstruct = getDialogSchema(this, name)

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

switch (name)
    case 'MessageBox'
        dlgstruct = i_message_box(this);
    case 'InputDialog'
        dlgstruct = i_input_dialog(this);
    case 'ErrorDialog'
        dlgstruct = i_error_dialog(this);
    case 'QuestionDialog'
        dlgstruct = i_question_dialog(this);
    case 'ListDialog'
        dlgstruct = i_list_dialog(this);
    otherwise
        dependencies.assert(false,...
            sprintf('Unexpected dialog schema name: %s',name));
end

end

%----------------------------------------------------
function dlgstruct = i_input_dialog(this)

data = this.pDialogData;
dlgstruct.DialogTitle = data.Title;

prompt.Type = 'text';
prompt.Name = data.Prompt;
prompt.Tag = 'prompt';
prompt.ColSpan = [1 1];
prompt.RowSpan = [1 1];

if data.InputDlgMultiline
    input.Type = 'editarea';
else
    input.Type = 'edit';
end
input.Value = data.DefaultAnswer;
input.Tag = 'input';
input.ColSpan = [1 1];
input.RowSpan = [2 2];

dlgstruct.LayoutGrid = [2 1];
dlgstruct.StandaloneButtonSet = {'OK','Cancel'};
dlgstruct.Sticky = true; % modal
dlgstruct.DialogTag = 'inputdlg';
dlgstruct = i_dialog_callback(dlgstruct,'inputdlg');
dlgstruct.Source = this;
dlgstruct.Items = {prompt, input};

end

%----------------------------------------------------
function dlgstruct = i_error_dialog(this)

data = this.pDialogData;
dlgstruct.DialogTitle = data.Title;

message.Type = 'text';
message.Name = data.Message;
message.Alignment = 5; % centre left
message.Tag = 'message';
message.ColSpan = [2 2];
message.RowSpan = [1 1];

image.Type = 'image';
image.Tag = 'image';
image.Alignment = 5; % centre left
image.RowSpan = [1 1];
image.ColSpan = [1 1];
image.FilePath = fullfile(matlabroot,'toolbox','shared','dastudio','resources','error.png');

% Create our own "OK" button so that we can centre it.
button.Type = 'pushbutton';
button.Name = 'OK';
button = i_control_callback(button,'ErrorDlg');

buttonGroup.Type = 'panel';
buttonGroup.LayoutGrid = [1 1];
buttonGroup.Items = {button};
buttonGroup.RowSpan = [2 2];
buttonGroup.ColSpan = [1 2];
buttonGroup.Alignment = 6; % button uses its own size; centred in both directions

dlgstruct.LayoutGrid = [2 2];
dlgstruct.StandaloneButtonSet = {''}; % no button bar
dlgstruct.Sticky = true; % modal
dlgstruct.DialogTag = 'errordlg';
dlgstruct.Items = {image, message, buttonGroup};

end

%----------------------------------------------------
function dlgstruct = i_message_box(this)

data = this.pDialogData;
dlgstruct.DialogTitle = data.Title;

message.Type = 'text';
message.Name = data.Message;
message.Alignment = 6; % centre in both directions
message.Tag = 'message';
message.ColSpan = [1 1];
message.RowSpan = [1 1];

% Create our own "OK" button so that we can centre it.
button.Type = 'pushbutton';
button.Name = 'OK';
button = i_control_callback(button,'MsgBox');

buttonGroup.Type = 'panel';
buttonGroup.LayoutGrid = [1 1];
buttonGroup.Items = {button};
buttonGroup.RowSpan = [2 2];
buttonGroup.ColSpan = [1 1];
buttonGroup.Alignment = 6; % button uses its own size; centred in both directions

dlgstruct.LayoutGrid = [2 1];
dlgstruct.StandaloneButtonSet = {''}; % no button bar
dlgstruct.Sticky = true; % modal
dlgstruct.DialogTag = 'msgbox';
dlgstruct.Items = {message, buttonGroup};

end

%----------------------------------------------------
function dlgstruct = i_question_dialog(this)

data = this.pDialogData;
dlgstruct.DialogTitle = data.Title;

prompt.Type = 'text';
prompt.Name = data.Prompt;
prompt.Alignment = 5; % centre left
prompt.Tag = 'message';
prompt.ColSpan = [2 2];
prompt.RowSpan = [1 1];

image.Type = 'image';
image.Tag = 'image';
image.Alignment = 5; % centre left
image.RowSpan = [1 1];
image.ColSpan = [1 1];
image.FilePath = fullfile(matlabroot,'toolbox','shared','dastudio','resources','question.png');

items = cell(1,numel(data.Buttons));
for i=1:numel(items)
    button.Type = 'pushbutton';
    button.Name = data.Buttons{i};
    tag = ['QuestDlg_',data.Buttons{i}];
    button.Tag = tag;
    button = i_control_callback(button,tag);    
    button.RowSpan = [1 1];
	button.ColSpan = [i i];
    items{i} = button;
end

buttonGroup.Type = 'panel';
buttonGroup.LayoutGrid = [1 1];
buttonGroup.Items = items;
buttonGroup.RowSpan = [2 2];
buttonGroup.ColSpan = [1 2];
buttonGroup.Alignment = 6; % centred in both directions

dlgstruct.LayoutGrid = [2 2];
dlgstruct.StandaloneButtonSet = {''}; % no button bar
dlgstruct.Sticky = true; % modal
dlgstruct.DialogTag = 'questdlg';
dlgstruct.Items = {image, prompt, buttonGroup};

end

%----------------------------------------------------
function dlgstruct = i_list_dialog(this)

data = this.pDialogData;
hasinfo = ~isempty(data.ItemInfo);

prompt.Type = 'text';
prompt.Name = data.Prompt;
prompt.Alignment = 5; % centre left
prompt.Tag = 'message';
prompt.ColSpan = [1 1];
prompt.RowSpan = [1 1];

list.Type = 'listbox';
list.ColSpan = [1 1];
list.RowSpan = [2 2];
list.Tag = 'list';
list.ListDoubleClickCallback = @i_doubleclick;
list.MultiSelect = false;
list.Entries = data.ListString;
if hasinfo
    list = i_control_callback(list,'list');
end

info.Type = 'text';
info.Name = sprintf(' \n \n%s\n \n',... % leave some space
    DAStudio.message('Shared:message:ClickForDescription'));
info.Tag = 'info';
info.WordWrap = true;
info.ColSpan = [1 1];
info.RowSpan = [3 3];

if hasinfo
    dlgstruct.LayoutGrid = [3 1];
    dlgstruct.Items = {prompt, list, info};
else
    dlgstruct.LayoutGrid = [2 1];
    dlgstruct.Items = {prompt, list};
end
dlgstruct.StandaloneButtonSet = {'OK','Cancel'};
dlgstruct.Sticky = true; % modal
dlgstruct.DialogTag = 'listdlg';
dlgstruct.DialogTitle = data.Title;
dlgstruct = i_dialog_callback(dlgstruct,'listdlg');

end

%--------------------------
function i_doubleclick(dlg,tag,index) %#ok<INUSD>
obj = dlg.getSource;
obj.pDialogCallback('listdlg',dlg);
delete(dlg);
end

%--------------------------
function item = i_control_callback(item,key)
item.ObjectMethod = 'pControlCallback';
item.MethodArgs = {key,'%dialog'};
item.ArgDataTypes = {'string','handle'};
end


%--------------------------
function s = i_dialog_callback(s,key)
s.PreApplyMethod = 'pDialogCallback';
s.PreApplyArgs = {key,'%dialog'};
s.PreApplyArgsDT = {'string','handle'};
end
