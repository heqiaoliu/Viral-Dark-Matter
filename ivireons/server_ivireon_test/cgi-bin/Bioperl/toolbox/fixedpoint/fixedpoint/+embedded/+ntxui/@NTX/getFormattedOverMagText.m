function overStr = getFormattedOverMagText(overExp)
% Return formatted overflow magnitude text

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:15 $

% MagDispOption:
%   1 = <value>-eps (overflow)
%       <value>     (underflow)
%   2 = <value>-eps for value >= 1, (overflow)
%       <1/value>-eps for value < 1 (overflow)
%       <value>  for value >=1,     (underflow)
%       <1/value> for value < 1     (underflow)
MagDispOption = 2;
overVal = 2.^overExp;
switch MagDispOption
    case 1
        % Alt 1: <value>-eps
        overStr = sprintf('%g-eps',overVal);
    otherwise % case 2
        % Alt 2: <value>-eps for value>0,
        %        <1/|value|>-eps otherwise
        if overExp < 0
            overStr = sprintf('1/%g-eps',2.^(-overExp));
        else
            overStr = sprintf('%g-eps',overVal);
        end
end
