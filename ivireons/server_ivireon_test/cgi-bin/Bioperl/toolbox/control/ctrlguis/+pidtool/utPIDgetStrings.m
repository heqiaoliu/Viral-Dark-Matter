function str = utPIDgetStrings(product,key,count)
% PID helper function

% This function returns string(s) based on the key

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2010/03/26 17:21:35 $

if strcmpi(product,'cst')
    prefix = 'Control:pidtool:';
else
    prefix = 'Slcontrol:pidtuner:';
end
if nargin==2
    str = ctrlMsgUtils.message([prefix key]);
elseif nargin==3
    str = cell(count,1);
    for ct=1:count
        str{ct} = ctrlMsgUtils.message([prefix key num2str(ct)]);
    end
end
