function varargout = abstract_genmcode(h, d)
%ABSTRACT_GENMCODE

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:09:07 $

[Fpass, Fstop, Apass, Astop] = getdesignspecs(h,d);

p = {'Fpass', 'Fstop', 'Apass', 'Astop'};
v = {getmcode(d, Fpass), getmcode(d, Fstop), getmcode(d, Apass), getmcode(d, Astop)};

if nargout == 1,
    b = sigcodegen.mcodebuffer;

    b.addcr(b.formatparams(p, v));

    varargout = {b};
else
    varargout = {p, v, {'', '', '', ''}};
end

% [EOF]
