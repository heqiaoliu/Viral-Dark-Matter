function this = SISODesignTask(sisodb)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:49:56 $

this = sisogui.SISODesignTask;

this.Parent = sisodb;

this.buildPanel;

