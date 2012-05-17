function [s,g] = mybilineardesign(h,has,c)
%MYBILINEARDESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:54:43 $

% Design analog filter
N = has.FilterOrder;
if rem(N,2) == 1,
    error(generatemsgid('oddOrder'),...
        'Filter order must be an even integer.');
end
if rem(N,4) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    error(generatemsgid('twiceEvenOrder'),...
        'Half of the filter order must be an odd integer for the filter structure specified.');
end

wp = has.Wpass;
rp = has.Apass;
rs = has.Astop;
[sa,ga] = alpastop(h,N/2,wp,rp,rs); % Halve the order

[s,g] = thisbilineardesign(h,N,sa,ga,c);

% [EOF]
