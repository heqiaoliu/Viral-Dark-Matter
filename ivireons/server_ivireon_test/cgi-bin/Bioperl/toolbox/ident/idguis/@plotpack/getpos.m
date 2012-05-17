function Pos = getpos(Block, Loc);
% ------------------------------------------------------------------------%
% Function: getpos
% Purpose: (Loopstruct.m) Gets top, left, bottom, right center edge block 
%           coordinates
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:39 $


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



