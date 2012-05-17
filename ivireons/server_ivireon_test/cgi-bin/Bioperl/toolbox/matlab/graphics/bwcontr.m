function newcolor = bwcontr(cc)
%BWCONTR Contrasting black or white color.
%   NEW = BWCONTR(COLOR) produces a black or white depending on which
%   one would contrast the most.  Used by NODITHER.
 
%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2005/10/28 15:53:32 $

if (ischar(cc))
    warning('MATLAB:bwcontr:PassingAString', [mfilename ' was passed a string -- using black'])
    newcolor = [0 0 0];
else
    if ((cc * [.3; .59; .11]) > .75)
        newcolor = [0 0 0];
    else
        newcolor = [1 1 1];
    end
end
