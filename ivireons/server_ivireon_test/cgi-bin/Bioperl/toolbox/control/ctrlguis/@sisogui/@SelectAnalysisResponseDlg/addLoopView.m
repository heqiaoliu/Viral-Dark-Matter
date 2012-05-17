function AddLoopView(this,loopdata,LoopTF)
%ADDLOOPVIEW  Add a loop view.

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2006/01/26 01:47:23 $

ColorStyle = {'b', 'g', 'r', 'c', 'm', 'y', ...
    'b--', 'g--', 'r--', 'c--', 'm--', 'y--', ...
    'b-.', 'g-.', 'r-.', 'c-.', 'm-.', 'y-.', ...
    'b^', 'g^', 'r^', 'c^', 'm^', 'y^'};

LoopTF.Style = ColorStyle{mod(length(loopdata.LoopView),length(ColorStyle))+1};
loopdata.LoopView(end+1,1) = LoopTF;
end