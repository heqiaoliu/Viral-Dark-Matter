function [isvalid,errmsg,msgid] = validate(h,specs)
%VALIDATE   Perform algorithm specific spec. validation.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 08:16:46 $

% Need to overload inherited one
isvalid = true;
errmsg = '';
msgid = '';


% [EOF]
