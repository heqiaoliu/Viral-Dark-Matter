function show(this)

if isempty(this.Dialog) || ~ishandle(this.Dialog)
    this.Dialog = DAStudio.Dialog(this);
else
    this.Dialog.show;
end