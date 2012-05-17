function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/03/02 10:18:24 $

args = getarguments(h, d);

N = get(d, 'Order');

opt = {};
if rem(N,2),
    % Design a type 4 filter
    opt = {'Hilbert'};
end

b = firls(N, args{:}, opt{:});

% Construct object
Hd = dfilt.dffir(b);

% [EOF]
