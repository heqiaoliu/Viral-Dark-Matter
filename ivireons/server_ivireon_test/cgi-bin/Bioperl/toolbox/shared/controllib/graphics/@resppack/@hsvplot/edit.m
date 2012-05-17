function edit(this,PropEdit)
%EDIT  Configures Property Editor for response plots.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:20:59 $

Axes = this.AxesGrid;
Tabs = PropEdit.Tabs;

% Labels tab
LabelBox = this.editLabels('Labels',Tabs(1).Contents);
Tabs(1) = PropEdit.buildtab(Tabs(1),LabelBox);

% Limits tab
XlimBox = Axes.editLimits('X','X-Limits',Tabs(2).Contents);
YlimBox = Axes.editLimits('Y','Y-Limits',Tabs(2).Contents);
Tabs(2) = PropEdit.buildtab(Tabs(2),[XlimBox;YlimBox]);

% Style
AxStyle  = Axes.AxesStyle;
GridBox  = Axes.editGrid('Grid' ,Tabs(3).Contents);
FontBox  = Axes.editFont('Fonts',Tabs(3).Contents);
ColorBox = AxStyle.editColors('Colors',Tabs(3).Contents);
Tabs(3)  = PropEdit.buildtab(Tabs(3),[GridBox;FontBox;ColorBox]);

set(PropEdit.Java.Frame,'Title',...
   sprintf('Property Editor: %s',this.AxesGrid.Title));
PropEdit.Tabs = Tabs;

%------------------- Local Functions ------------------------------
