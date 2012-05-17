function addLoopView(this,LoopTF)
%ADDLOOPVIEW  Add a loop view.

%   Authors: A. Stothert
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.10.1 $ $Date: 2006/03/26 01:11:04 $

ColorStyle = {'b', 'g', 'r', 'c', 'm', 'y', ...
    'b--', 'g--', 'r--', 'c--', 'm--', 'y--', ...
    'b-.', 'g-.', 'r-.', 'c-.', 'm-.', 'y-.', ...
    'b^', 'g^', 'r^', 'c^', 'm^', 'y^'};

LoopTF.Style = ColorStyle{mod(length(this.LoopView),length(ColorStyle))+1};
this.LoopView(end+1,1) = LoopTF;
