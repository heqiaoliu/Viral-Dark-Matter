function varargout = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.7 $  $Date: 2007/12/14 15:12:18 $

[Fstop1, Fstop2, Astop] = getdesignspecs(h, d);

if nargout == 1,
    hfdesign = fdesign.bandpass('N,Fst1,Fst2,Ast', d.Order, Fstop1, Fstop2, Astop);
    Hd       = cheby2(hfdesign);
    
    varargout = {Hd};
else

    % Set up design params
    N = get(d,'order');

    if rem(N,2),
        error(generatemsgid('MustBeEven'),'Bandpass designs must be of even order.');
    end

    F = [Fstop1 Fstop2];

    [z,p,k] = cheby2(N/2,Astop,F);
    
    varargout = {z,p,k};
end

% [EOF]
