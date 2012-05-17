function display(this)
% DISPLAY the operating point object

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:17:29 $

header = 'Operating point specifications for Hammerstein-Wiener model';
inputstr = 'Input specifications:';
outputstr = 'Output specifications:';

disp(header)
disp(inputstr)
disp(this.Input)
disp(' ')
disp(outputstr)
disp(this.Output)
