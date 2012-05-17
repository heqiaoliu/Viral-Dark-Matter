function underStr = getFormattedUnderMagText(underExp)
% Return formatted underflow magnitude text

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:16 $

% Update magnitude text readouts
%
% MagDispOption:
%   1 = <value>-eps (overflow)
%       <value>     (underflow)
%   2 = <value>-eps for value >= 1, (overflow)
%       <1/value>-eps for value < 1 (overflow)
%       <value>  for value >=1,     (underflow)
%       <1/value> for value < 1     (underflow)
MagDispOption = 2;
underVal = 2.^underExp;
switch MagDispOption
    case 1
        % Alt 1: <value>-eps
        underStr = sprintf('%g',underVal);
    otherwise % case 2
        % Alt 2: <value>-eps for value>0,
        %        <1/|value|>-eps otherwise
        if underExp < 0
            underStr = sprintf('1/%g',2.^(-underExp));
        else
            underStr = sprintf('%g',underVal);
        end
end
