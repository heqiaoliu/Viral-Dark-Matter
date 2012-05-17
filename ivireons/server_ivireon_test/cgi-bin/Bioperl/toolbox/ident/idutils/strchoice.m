function [value, msg] = strchoice(strlist, instr, property)
%STRCHOICE string choice among a given list.
%  Return the error message if no or non unique result
%  Syntax: value = strchoice(strlist, instr)
%          [value, msg] = strchoice(strlist, instr, property)
%          Note: msg and property must be used together.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/12/05 02:04:15 $

% Author(s): Qinghua Zhang

no = nargout;
if ~iscellstr(strlist)
    ctrlMsgUtils.error('Ident:utility:strchoice1')
end
if ~ischar(instr)
    value = '';
    if no>1
        msg = sprintf('The value of the "%s" property must be one of %s.',property,listmsg(strlist));
        msg = struct('identifier','Ident:general:enumPropVal','message',msg);
    end
    return
end

ind = strmatch(lower(instr), lower(strlist));
if length(ind)~=1
    value = '';
    if no>1
        msg = sprintf('The value of the "%s" property must be one of %s.',property,listmsg(strlist));
        msg = struct('identifier','Ident:general:enumPropVal','message',msg);
    end
else
    value = strlist{ind};
    msg = struct([]);
end

%--------------------------------------------------------------------------
function msg = listmsg(cstr)

nstr = length(cstr);
msg = '';
for k=1:nstr-1
    msg = [msg, '''', cstr{k}, '''', ', '];
end
msg = [msg, '''', cstr{nstr}, ''''];

% FILE END