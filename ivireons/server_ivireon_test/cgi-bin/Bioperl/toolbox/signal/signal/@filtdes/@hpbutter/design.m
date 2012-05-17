function varargout = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.6 $  $Date: 2005/12/22 19:01:50 $

if nargout == 1,
    hfdesign = fdesign.highpass('N,Fc', d.Order, d.Fc);
    Hd       = butter(hfdesign);
    
    varargout = {Hd};
else

    % Set up design params
    N = get(d,'order');

    % Get frequency specs, they have been prenormalized
    Fc = get(d,'Fc');

    [z,p,k] = butter(N,Fc,'high');

    varargout = {z,p,k};
end

% [EOF]
