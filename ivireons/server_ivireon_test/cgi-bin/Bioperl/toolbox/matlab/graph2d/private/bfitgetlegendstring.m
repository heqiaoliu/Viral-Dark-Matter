function legstring = bfitgetlegendstring(whichstring,strtype,maxstringlength)
% BFITGETLEGENDSTRING Get the string for the legend on figure for Data Stats 
%    and Basic Fitting GUIs.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/27 18:07:57 $

start = 4;
legstring = blanks(maxstringlength);
if maxstringlength < 16
    error('MATLAB:bfitcreatelegend:LegendStringLength', 'Maxstringlength must be at least 16.')
end

switch whichstring
case {'fit'}
    switch strtype
    case 0
        legstring(start:start+5) = 'spline';
    case 1
        legstring(start:start+15) = 'shape-preserving';
    case 2
        legstring(start:start+5) = 'linear';
    case 3
        legstring(start:start+8) = 'quadratic';
    case 4
        legstring(start:start+4) = 'cubic';
    otherwise
        if (strtype==11)
            legstring(start:start+10) = [num2str(strtype-1),'th degree'];
        else
            legstring(start:start+9) = [num2str(strtype-1),'th degree'];
        end
    end
case {'xstat','ystat'}
    if isequal('xstat',whichstring)
        legstring(start) = 'x';
    else
        legstring(start) = 'y';
    end
    startplusskip = start + 2;
    switch strtype
    case 1
        legstring(startplusskip:startplusskip+2) = 'min';
    case 2
        legstring(startplusskip:startplusskip+2) = 'max';
    case 3
        legstring(startplusskip:startplusskip+3) = 'mean';
    case 4
        legstring(startplusskip:startplusskip+5) = 'median';
    case 5
        legstring(startplusskip:startplusskip+3) = 'mode';
    case 6
        legstring(startplusskip:startplusskip+2) = 'std';
    otherwise
        error('MATLAB:bfitcreatelegend:LegendNoRangeString','No legend string for range.')
    end
case 'eval results'
    legstring(start:start+7) = 'Y = f(X)';
otherwise
    error('MATLAB:bfitcreatelegend:NoStringType', 'No such whichstring strtype.')
end    
