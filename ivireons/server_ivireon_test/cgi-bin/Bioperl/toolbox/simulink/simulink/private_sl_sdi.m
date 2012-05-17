function private_sl_sdi(bd)
% Copyright 2010 The MathWorks, Inc.

    try
        Simulink.sdi.view;
		gui = Simulink.sdi.Instance.getMainGUI();  
		sde = gui.SDIEngine;
        sde.createRunFromModel(bd);        
        gui.updateGUI();
        
    catch ME
        errordlg(ME.message, 'Error', 'modal');
    end

