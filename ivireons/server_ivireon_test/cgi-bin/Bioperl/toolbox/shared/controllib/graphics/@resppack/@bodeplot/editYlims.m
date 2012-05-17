function YlimBox = editYlims(this,TabContents)
%EDITYLIMS  Builds group box for Y limit editing.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:20:10 $

% Build standard Y-limit box
YlimBox = this.AxesGrid.editLimits('Y','Y-Limits',TabContents);

% Add Mag/Phase labels
s = get(YlimBox.GroupBox,'UserData'); % Java handles
s.LimRows(1).Label.setText(sprintf('(Magnitude)'))
s.LimRows(2).Label.setText(sprintf('(Phase)'))