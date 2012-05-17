function varargout = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2005/12/22 19:01:56 $

% Set up design params
[Fpass, Apass, Astop] = getdesignspecs(h, d);

if nargout == 1,
    hfdesign = fdesign.highpass('N,Fp,Ast,Ap', d.Order, Fpass, Astop, Apass);
    Hd       = ellip(hfdesign);
    
    varargout = {Hd};
else
    [z,p,k] = ellip(d.Order,Apass,Astop,Fpass,'high');
    varargout = {z,p,k};
end

% [EOF]
