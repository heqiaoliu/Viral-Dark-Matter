function dlgstruct = coder_opts_ddg(h, name)

% Copyright 2002-2005 The MathWorks, Inc.

  %------------------------------------------------------------------
  % First row
  %------------------------------------------------------------------
  % Name label
  lblName.Name    = 'Target Name:';
  lblName.Type    = 'text';
  lblName.RowSpan = [1 1];
  lblName.ColSpan = [1 3];
  lblName.Tag = strcat('sfCoderoptsdlg_', lblName.Name);

  % Name text
  txtName.Name    = h.Name;
  txtName.Type    = 'text';
  txtName.RowSpan = [1 1];
  txtName.ColSpan = [4 10];
  txtName.Tag = strcat('sfCoderoptsdlg_', txtName.Name);
 
  %------------------------------------------------------------------
  % Second row
  %------------------------------------------------------------------
  % Generate the dialog from the flag info on the target
  flags = target_methods('codeflags',h.Id);
  grpMain.Items = {};

  % for each supported flag, create the widget struct
  for i = 1:length(flags)
    flag     = flags(i);
       
    val = flag.value;
    if(val == -1)
      val = flag.defaultValue;
    end
    
    wid.Name = flag.description;
    
    switch(flag.type)
     case 'boolean'
      wid.Type = 'checkbox';
     case 'enumeration'
      wid.Type = 'combobox';
      wid.Entries = flag.values;
        case 'word'
            wid.Type = 'edit';
    end
    
    wid.Value           = val;
    wid.Tag             = int2str(i);
    grpMain.Items{i}    = wid;
  end

  grpMain.Name       = 'Coder Options';
  grpMain.Type       = 'group';
  grpMain.RowSpan    = [2 2];
  grpMain.ColSpan    = [1 10];
  grpMain.Tag        = strcat('sfCoderoptsdlg_', grpMain.Name);

  % main panel
  pnlMain.Type       = 'panel';
  pnlMain.LayoutGrid = [2 2];
  pnlMain.Items      = {lblName, txtName, grpMain};
  pnlMain.Tag        = 'sfCoderoptsdlg_pnlMain';
                
  %------------------------------------------------------------------
  % Main dialog
  %------------------------------------------------------------------
  dlgstruct.DialogTitle = ['Stateflow ', h.Name, ' Coder Options'];
  dlgstruct.PreApplyCallback = 'sf';
  dlgstruct.PreApplyArgs     = {'Private', 'coder_opts_ddg_preapply_cb', '%dialog', length(flags)};
  dlgstruct.SmartApply       = 0;
  dlgstruct.Items            = {pnlMain};
  dlgstruct.DialogTag        = create_unique_dialog_tag(h, 'Coder_Options');
  dlgstruct.HelpMethod       = 'sfhelp';
  if (strcmp(h.Name, 'sfun'))
    dlgstruct.HelpArgs         = {h,'SIM_CODER_OPTIONS'};
  elseif (strcmp(h.Name, 'rtw'))
    dlgstruct.HelpArgs         = {h,'RTW_CODER_OPTIONS'};
  else
    dlgstruct.HelpArgs         = {h,'CUS_CODER_OPTIONS'};
  end
  dlgstruct.DisableDialog = ~is_object_editable(h);
