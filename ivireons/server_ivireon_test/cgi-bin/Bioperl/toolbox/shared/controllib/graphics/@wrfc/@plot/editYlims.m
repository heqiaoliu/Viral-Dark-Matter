function YlimBox = editYlims(this,TabContents)
%EDITYLIMS  Builds group box for Y limit editing.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:29:23 $

% Default implementation (standard limit editor)
YlimBox = this.AxesGrid.editLimits('Y','Y-Limits',TabContents);