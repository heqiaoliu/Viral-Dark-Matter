function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2007/12/14 15:12:35 $

args = getarguments(h, d);

N = get(d, 'Order');

if rem(N,2),
    % Cannot design odd order bandstops
    error(generatemsgid('MustBeEven'),'Cannot design filter, try making the order even.');
end

b = firls(N, args{:});

% Construct object
Hd = dfilt.dffir(b);

% [EOF]
