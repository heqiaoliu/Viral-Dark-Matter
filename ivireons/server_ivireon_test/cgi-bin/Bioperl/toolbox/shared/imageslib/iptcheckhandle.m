function iptcheckhandle(h,valid_types,function_name,variable_name,argument_position)
%IPTCHECKHANDLE Check validity of handle.
%   IPTCHECKHANDLE(H,VALID_TYPES,FUNC_NAME,VAR_NAME,ARG_POS) 
%   checks the validity of the handle H and issues a formatted error
%   message if it is invalid. H must be a handle to a single 
%   figure, uipanel, hggroup, axes, or image object.
%
%   VALID_TYPES is a cell array of strings specifying the set of Handle
%   Graphics object types to which H is expected to belong. For example,
%   if you specify valid_types as {'uipanel','figure'}, H can be either
%   a handle to a uipanel object or a figure object.
%
%   FUNC_NAME is a string that specifies the name used in the formatted
%   error message to identify the function checking the handle.
%
%   VAR_NAME is a string that specifies the name used in the formatted
%   error message to identify the argument being checked.
%
%   ARG_POS is a positive integer that indicates the position of
%   the argument being checked in the function argument list. 
%   IPTCHECKHANDLE converts this number to an ordinal number and includes
%   this information in the formatted error message.
%
%   Example
%   -------
%   % To trigger this error message, create a figure that does not contain 
%   % an axes and then check for a valid axes handle.   
%   fig = figure; 
%   iptcheckhandle(fig,{'axes'},'my_function','my_variable',2)     
%
%   See also IPTCHECKINPUT, IPTCHECKMAP, IPTCHECKNARGIN, IPTCHECKSTRS,
%            IPTNUM2ORDINAL.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/12/22 23:50:45 $

%%%%%%%%
% Catch errors in use of IPTCHECKHANDLE
% Check that valid_types is a cell array containing these HG objects:
allowed_types = {'figure', 'uipanel', 'uicontainer', ...
                 'hggroup', 'axes', 'image'};
if ~iscell(valid_types) 
    eid = sprintf('Images:%s:expectCellValidTypes', mfilename);
    error(eid,'Expected VALID_TYPES to be a cell array.');
end

for i = 1:numel(valid_types)
    if ~any(strcmpi(valid_types{i},allowed_types))
        list = cell2list(allowed_types);
        eid = sprintf('Images:%s:typeNotSupported', mfilename);
        error(eid,...
              'Expected VALID_TYPES to be a subset of this list:\n\n  %s',...
              list);
    end
end
%%%%%%%%


if ~isscalar(h) || ~ishghandle(h)    
    msgId = sprintf('Images:%s:invalidHandle',function_name);
    error(msgId,'Function %s expected its %s input argument, %s, to be a valid handle to a single graphics object.', ...
          upper(function_name), iptnum2ordinal(argument_position), variable_name);
end

type = get(h,'Type');

% Check that the type of h matches one of the valid_types
if ~any(strcmpi(type,valid_types));
    
    list = cell2list(valid_types);
    
    msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
                   upper(function_name), iptnum2ordinal(argument_position), ...
                   variable_name);
    msg2 = 'to be a handle of one of these types:';
    
    msg3 = sprintf('Instead, its type was: %s.', type);
    eid = sprintf('Images:%s:invalidHandleType', function_name);
    
    error(eid,'%s\n%s\n\n  %s\n\n%s', msg1, msg2, list, msg3);

end

%---------------------------------------
% Convert cell_array containing strings to a single string containing a
% space-separated list of valid strings.
function list = cell2list(cell_array)

list = '';
for k = 1:length(cell_array)
    list = [list ', ' cell_array{k}];
end
list(1:2) = [];
