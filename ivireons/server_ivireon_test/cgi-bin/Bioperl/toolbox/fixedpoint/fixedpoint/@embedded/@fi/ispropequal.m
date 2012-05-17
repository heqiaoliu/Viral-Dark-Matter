function t = ispropequal(A,B)
%ISPROPEQUAL True if all properties are equal
%   ISPROPEQUAL(A,B) returns 1 if all of the properties and values of A
%   and B are equal.
%
%   See also EMBEDDED.FI/ISEQUAL

%   Thomas A. Bryan, 15 January 2004
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/11/13 17:56:28 $

error(nargchk(2,2,nargin,'struct'));
if isfi(A) && isfi(B) && isfimathlocal(A) && isfimathlocal(B)
    t = isfi(A) && isfi(B) && ...
        isequal(struct(A),struct(B)) && isequal(A.intarray, B.intarray);
else
    t = isfi(A) && isfi(B) && isequal(struct(numerictype(A)),struct(numerictype(B))) && ...
        isequal(A.intarray, B.intarray);
end
