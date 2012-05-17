function varargout = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.6 $  $Date: 2005/12/22 19:02:06 $

if nargout == 1,
    hfdesign = fdesign.lowpass('N,Fc', d.Order, d.Fc);
    Hd       = butter(hfdesign);
    
    varargout = {Hd};
else
    [z,p,k] = butter(d.Order, d.Fc);
    
    varargout = {z,p,k};
end

% [EOF]
