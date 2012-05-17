function str = initdisplay(this,x,optimValues)
% STR = INITDISPLAY(THIS,X,OPTIMVALUES,STATE)

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/04/18 22:18:56 $

str = cell(5,1);
str{1} = '<font face="monospaced"; size=3>';
str{2} = xlate(' Optimizing to solve for all desired dx/dt=0, x(k+1)-x(k)=0, and y=ydes.');
str{3} = ' ';
str{4} = xlate('(Maximum Error)  Block');
str{5} = ' ---------------------------------------------------------';
