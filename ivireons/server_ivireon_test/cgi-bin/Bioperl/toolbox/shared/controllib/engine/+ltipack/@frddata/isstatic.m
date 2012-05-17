function boo = isstatic(D)
% True for static gains

%   Author: S. Almy
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:37 $
if hasdelay(D)
   boo = false;
else
   % Static gain must have constant response
   fvar = diff(D.Response,1,3);
   boo = ~any(fvar(:));
end