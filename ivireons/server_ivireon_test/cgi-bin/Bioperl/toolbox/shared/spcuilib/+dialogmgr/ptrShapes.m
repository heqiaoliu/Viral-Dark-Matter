function icons = ptrShapes
% Returns a structure of cursor icons.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:20 $

% Color support:
% k = black
% w = white
% NaN = transparent
% NOTE: o in matrix is mapped to NaN for use in final icon


o=NaN; w=2; k=1;

x=[ o o o o o w k w w k w o o o o o ;
    o o o o o w k w w k w o o o o o ;
    o o o o o w k w w k w o o o o o ;
    o o o o o w k w w k w o o o o o ;
    o o w w w w k w w k w w w w o o ;
    o w k w w w k w w k w w w k w o ;
    w k k w w w k w w k w w w k k w ;
    k k k k k k k w w k k k k k k k ;
    w k k w w w k w w k w w w k k w ;
    o w k w w w k w w k w w w k w o ;
    o o w w w w k w w k w w w w o o ;
    o o o o o w k w w k w o o o o o ;
    o o o o o w k w w k w o o o o o ;
    o o o o o w k w w k o o o o o o ;
    o o o o o w k w w k w o o o o o ;
    o o o o o o o o o o o o o o o o ];

icons.HorizSplitter = x;

