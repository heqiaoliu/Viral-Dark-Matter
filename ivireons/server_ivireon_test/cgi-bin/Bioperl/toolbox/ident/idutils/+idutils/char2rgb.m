function Col = char2rgb(v)
% Convert standard color identifier characters to (normalized) RGB values.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2008/12/29 02:08:02 $

switch lower(v)
    case 'b'
        Col = [0 0 1];
    case 'y'
        Col = [1 1 0];
    case 'm'
        Col = [1 0 1];
    case 'c'
        Col = [0 1 1];
    case 'r'
        Col = [1 0 0];
    case 'g'
        Col = [0 1 0];
    case 'w'
        Col = [1 1 1];
    case 'k'
        Col = [0 0 0];
end %switch
