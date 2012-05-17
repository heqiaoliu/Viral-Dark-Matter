function [s,g] = mybilineardesign(h,has,c)
%MYBILINEARDESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:56:14 $

% Design analog filter
N = has.FilterOrder;
if rem(N,2) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    error(generatemsgid('evenOrder'),'Order must be odd for the filter structure specified.');
end

wp = has.Wpass;
ws = has.Wstop;
rp = has.Apass;
[sa,ga] = alpfstop(h,N,wp,ws,rp);

[s,g] = thisbilineardesign(h,N,sa,ga);

% [EOF]
