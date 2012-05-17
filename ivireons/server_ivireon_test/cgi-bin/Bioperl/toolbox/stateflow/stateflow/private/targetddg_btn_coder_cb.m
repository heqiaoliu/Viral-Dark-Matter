function [res, err] = targetddg_btn_coder_cb(h, subDialogName)

% Copyright 2003-2005 The MathWorks, Inc.

  subDialogTag = create_unique_dialog_tag(h, 'Coder_Options');
  hSubDialog = find_existing_dialog(subDialogTag);

  if ishandle(hSubDialog)
    hSubDialog.show;
  else  
    DAStudio.Dialog(h, 'Coder Options', 'DLG_STANDALONE');
  end

  err = [];
  res = 1;
