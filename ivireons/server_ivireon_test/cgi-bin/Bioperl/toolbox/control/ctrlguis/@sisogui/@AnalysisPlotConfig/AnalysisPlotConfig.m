function this = AnalysisPlotConfig(SISODB)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:49:00 $

this = sisogui.AnalysisPlotConfig;

this.SISODB = SISODB;
this.buildPanel;
this.initializeData;
this.refreshPanel;
this.addlisteners;




