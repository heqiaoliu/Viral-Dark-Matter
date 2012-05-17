function [isvalid,errmsg,msgid] = validate(h,specs)
%VALIDATE   Perform algorithm specific spec. validation.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 08:16:41 $

% Populate defaults
isvalid = true;
errmsg = '';
msgid = '';

if rem(specs.FilterOrder,2),
    isvalid = true;
    errmsg = 'Filter order must be even.';
    msgid =generatemsgid('invalidSpec');
end

% [EOF]
