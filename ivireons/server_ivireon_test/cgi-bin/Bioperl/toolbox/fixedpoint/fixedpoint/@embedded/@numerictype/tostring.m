%TOSTRING Convert numerictype object to string
%   S = TOSTRING(T) converts numerictype object T to a string S such that
%   EVAL(S) would create a numerictype object with the same properties as T.
%
%   Example:
%     t = numerictype(true,16,15);
%     s = tostring(t);
%     t1 = eval(s);
%     isequal(t,t1)
%     % returns 1
%
%   See also EVAL, NUMERICTYPE, EMBEDDED.QUANTIZER/TOSTRING

%   Copyright 1999-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/09/21 18:41:02 $
