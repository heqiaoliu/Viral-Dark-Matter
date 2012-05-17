function changeSimPrmTab(hDlg, tag, index)
% CHANGESIMPRMTAB

% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.1.6.8 $

  hSrc = getDialogSource(hDlg);

  if isa(hSrc, 'Simulink.ConfigSetRef')
      %There are no tabs
      return;
  end

  switch tag
   case 'Tag_ConfigSet_Sim_tabs'
    if isa(hSrc, 'Simulink.ConfigSet')
      hSrc = getComponent(hSrc, 'Simulation Target');
    end
   case 'Tag_ConfigSet_RTW_tabs'
    if isa(hSrc, 'Simulink.ConfigSet')
      hSrc = getComponent(hSrc, 'Real-Time Workshop');
    end
   case 'Tag_ConfigSet_Debug_tabs'
    if isa(hSrc, 'Simulink.DebuggingCC')
      controller = hSrc.getDialogController;
      set(controller, 'ActiveTab', index);
    end
    return;
  end
  set(hSrc, 'ActiveTab', index);
  
  % double operation to make sure that even if we are operating
  % on cache object; the tab selection is maintained
  if hSrc.isActive
    hMdl = hSrc.getModel;
    hSrc = getActiveConfigSet(hMdl);    
    switch tag
     case 'Tag_ConfigSet_Sim_tabs'
      if isa(hSrc, 'Simulink.ConfigSet')
        hSrc = getComponent(hSrc, 'Simulation Target');
      end
     case 'Tag_ConfigSet_RTW_tabs'
      if isa(hSrc, 'Simulink.ConfigSet')
        hSrc = getComponent(hSrc, 'Real-Time Workshop');
      end
    end
    set(hSrc, 'ActiveTab', index);
  end
    
