function AddLoopView(this,loopdata,LoopTF)
%ADDLOOPVIEW  Add a loop view.

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:50:16 $

ColorStyle = {'b', 'g', 'r', 'c', 'm', 'y', ...
    'b--', 'g--', 'r--', 'c--', 'm--', 'y--', ...
    'b-.', 'g-.', 'r-.', 'c-.', 'm-.', 'y-.', ...
    'b^', 'g^', 'r^', 'c^', 'm^', 'y^'};

LoopTF.Style = ColorStyle{mod(length(loopdata.LoopView),length(ColorStyle))+1};
loopdata.LoopView(end+1) = LoopTF;
end