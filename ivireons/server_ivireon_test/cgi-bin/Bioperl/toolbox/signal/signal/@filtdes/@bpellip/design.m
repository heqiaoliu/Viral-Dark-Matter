function varargout = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.7 $  $Date: 2007/12/14 15:12:19 $

[Fpass1, Fpass2, Apass, Astop] = getdesignspecs(h, d);

if nargout == 1,
    hfdesign = fdesign.bandpass('N,Fp1,Fp2,Ast1,Ap,Ast2', ...
        d.Order, d.Fpass1, d.Fpass2, Astop, Apass);
    Hd       = ellip(hfdesign);
        
    varargout = {Hd};
else
    N = get(d,'order');
    if rem(N,2),
        error(generatemsgid('MustBeEven'),'Bandpass designs must be of even order.');
    end

    F = [Fpass1 Fpass2];

    [z,p,k] = ellip(N/2,Apass,Astop,F);
    varargout = {z, p, k};
end

% [EOF]
