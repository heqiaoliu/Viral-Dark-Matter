function this = SystemConfig(SISODB)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 17:42:11 $

this = sisogui.SystemConfig;

this.SISODB = SISODB;
this.buildPanel;
% this.initializeData;
% this.refreshPanel;
this.addListeners;




