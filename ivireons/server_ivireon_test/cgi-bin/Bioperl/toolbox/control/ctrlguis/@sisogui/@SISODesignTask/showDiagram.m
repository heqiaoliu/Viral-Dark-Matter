function showDiagram(this,LoopConfig)
% showDiagram Display Architecture diagram

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2005/12/22 17:41:58 $

if nargin == 1
    LoopConfig = [];
end
if isempty(this.Diagram)
    this.Diagram = sisogui.DiagramDisplay(this.Parent.LoopData,LoopConfig);
else
    this.Diagram.LoopConfig = LoopConfig;
    this.Diagram.refreshDiagram;
end

this.Diagram.Figure.Visible = 'on';



