function [value, msg] = pvsearch(prop, pvpairs, casesens, command)
%PVSEARCH search for a property value in the list of PV-pairs.
%
%  [value, msg] = pvsearch(prop, pvpairs, casesens)
%  prop:     property name
%  pvpairs:  list of PV-pairs
%  casesens: case sensitiveness flag, true (false) if case (in)sensitive
%  command: name of function for which the pv check is being performed
%  value:    property value
%  msg:      error message

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/06/13 15:22:11 $

ni = nargin;
error(nargchk(2, 4, ni,'struct'))

if ni<3
    casesens = true;
    command = 'idnlmodel';
end

value = [];
msg = struct([]);
pargs = pvpairs(1:2:end);
if ~iscellstr(pargs)
    msg = sprintf('The value of the "%s" property must be specified. Type "help %s" for more information.',prop,command);
    msg = struct('identifier','Ident:general:missingPropSpec','message',msg);
    return
end

if casesens
    ind = strmatch(prop, pargs, 'exact');
else
    ind = strmatch(lower(strtrim(prop)), lower(strtrim(pargs)), 'exact');
end

if length(ind)==1
    value = pvpairs{ind*2};
elseif length(ind)>1
    msg = struct('identifier','Ident:general:ambiguousProp', 'message',...
        sprintf('The option ''%s'' specified for "%s" command is ambiguous. Specify more characters.',prop,command));
else
    msg = sprintf('The value of the "%s" property must be specified. Type "help %s" for more information.',prop,command);
    msg = struct('identifier','Ident:general:missingPropSpec','message',msg);
end

% FILE END