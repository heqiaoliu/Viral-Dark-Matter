function str = iterdisplayGUI(this,x,optimValues) %#ok<INUSD>
% STR = ITERDISPLAYGUI(THIS,X,OPTIMVALUES,STATE)

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $ $Date: 2007/10/15 23:31:34 $

if ~isempty([this.F_dx(:);this.F_y(:)])
    [element,type,max_val] = getLimitingConstraint(this);

    if strcmp(type,'block')
        str1 = sprintf('<a href="block:%s">%s</a>',element,element);
    else
        str1 = element;
    end
    str = {sprintf('(%0.5e) %s',max_val,str1)};
else
    str = {'There are no constraints to meet'};
end
