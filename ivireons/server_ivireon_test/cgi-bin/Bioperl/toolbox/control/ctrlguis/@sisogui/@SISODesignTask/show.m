function show(this,TargetTab)
% show Display Tab defined by TargetTab
%     TargetTab is a string. See setTab for more details.

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2007/02/06 19:50:46 $


if nargin == 1;
    TargetTab = 'Architecture';
end

%Bring CETM to front
projectframe = slctrlexplorer;
projectframe.setSelected(this.Parent.getNode.getTreeNodeInterface);
projectframe.toFront;
awtinvoke(projectframe,'setVisible(Z)',true);

% Set Target Tab of Design Task Panel
this.setTab(TargetTab);



