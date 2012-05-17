function errmsg = idlasterr(E)
% Extracts error message from LASTERR.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/31 06:14:00 $

if nargin<1
    msg = lasterr;
    check = true;
else
    msg = E.message;
    check = false;
end

if check
    [head, errmsg] = strtok( msg, sprintf('\n') );
    if isempty(errmsg)
        errmsg = head;
    elseif isempty(strfind(head,xlate('Error using')))
        errmsg = msg;
    end
    errmsg = strrep(errmsg,char(10),' ');
else
    errmsg = msg;
end

