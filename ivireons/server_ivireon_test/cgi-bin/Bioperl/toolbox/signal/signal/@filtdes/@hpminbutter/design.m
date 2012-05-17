function varargout = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.6 $  $Date: 2005/12/22 19:01:58 $

[Fstop, Fpass, Astop, Apass] = getdesignspecs(h, d);

if nargout == 1,
    hfdesign = fdesign.highpass(Fstop, Fpass, Astop, Apass);
    Hd       = butter(hfdesign, 'MatchExactly', d.MatchExactly);
    
    varargout = {Hd};
else

    [N,Fc] = buttord(Fpass,Fstop,Apass,Astop);

    [z,p,k] = butter(N,Fc,'high');
    
    varargout = {z,p,k};
end

% [EOF]
