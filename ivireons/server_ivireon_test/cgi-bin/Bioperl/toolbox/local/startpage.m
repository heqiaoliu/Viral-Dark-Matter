function startpage

%   Copyright 2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:23:03 $

if usejava('desktop')
    dt = com.mathworks.mde.desk.MLDesktop.getInstance();
    frame = dt.getMainFrame();
    sp = com.mathworks.mde.webintegration.startpage.StartPageFactory.getStartPage();
    if sp.isEnabled()
        sp.showStartPage(frame);
    else
        disp('The start page feature is not enabled.')
    end
else
        disp('The start page feature is not available with the -nodesktop option.')
end