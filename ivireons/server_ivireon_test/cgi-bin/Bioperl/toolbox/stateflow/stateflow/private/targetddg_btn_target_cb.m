function [res, err] = targetddg_btn_target_cb(h, subDialogName)

% Copyright 2003-2005 The MathWorks, Inc.

  subDialogTag = create_unique_dialog_tag(h, 'Target_Options');
  hSubDialog = find_existing_dialog(subDialogTag);

  if ishandle(hSubDialog)
    hSubDialog.show;
  else  
    DAStudio.Dialog(h, 'Target Options', 'DLG_STANDALONE');
  end

  err = [];
  res = 1;
