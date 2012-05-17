function Pos = getpos(Block, Loc);
% ------------------------------------------------------------------------%
% Function: getpos
% Purpose: (Loopstruct.m) Gets top, left, bottom, right center edge block 
%           coordinates
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.10.1 $ $Date: 2005/11/15 00:54:45 $


Position = Block.Position;

switch Loc
    case 'R'
        offset = Block.Width/2;
        Pos = [Position(1) + offset, Position(2)];

    case 'L'
        offset = Block.Width/2;
        Pos = [Position(1) - offset, Position(2)];

    case 'T'
        offset = Block.Height/2;
        Pos = [Position(1), Position(2) + offset];

    case 'B'
        offset = Block.Height/2;
        Pos = [Position(1), Position(2) - offset];
end



