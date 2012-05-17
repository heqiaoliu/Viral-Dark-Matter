function b = genmcode(h, d)
%GENMCODE Generate MATLAB code

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:52:55 $

b = sigcodegen.mcodebuffer;

b.addcr(b.formatparams({'N', 'Fpass'}, {getmcode(d, 'Order'), getmcode(d, 'Fpass')}))
b.cr;
b.addcr(designdesc(d));
b.addcr('b  = firhalfband(N, Fpass%s);', getfsstr(d));
b.add('Hd = dfilt.dffir(b);');

% [EOF]
