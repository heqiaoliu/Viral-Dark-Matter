function setBAWidgets(dlg)
% Impact of top-level strategy widget on other dialog widgets

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:49 $

setBAILWidgets(dlg);
setBAFLWidgets(dlg);
setBAILFLWidgets(dlg);

if (dlg.BAWLMethod == 1) && ~dlg.BAGraphicalMode %% auto and non-graphical
    disableBAILFLPanel(dlg);
    enableBAFLPanel(dlg);
    enableBAILPanel(dlg);
    disableBAWLPanel(dlg);
elseif (dlg.BAWLMethod == 1) && dlg.BAGraphicalMode %% auto & graphical
     disableBAILFLPanel(dlg);
     disableBAFLPanel(dlg);
     disableBAILPanel(dlg);
     disableBAWLPanel(dlg);
elseif (dlg.BAWLMethod == 2) && ~dlg.BAGraphicalMode %% specify and non-graphical
    enableBAILFLPanel(dlg);
    disableBAFLPanel(dlg);
    disableBAILPanel(dlg);
    enableBAWLPanel(dlg);
elseif (dlg.BAWLMethod == 2) && dlg.BAGraphicalMode %% specify and graphical
    disableBAILFLPanel(dlg);
    disableBAFLPanel(dlg);
    disableBAILPanel(dlg);
    enableBAWLPanel(dlg);
end


