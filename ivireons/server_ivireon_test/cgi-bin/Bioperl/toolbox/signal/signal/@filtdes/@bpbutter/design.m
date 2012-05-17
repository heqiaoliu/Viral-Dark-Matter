function varargout = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.7 $  $Date: 2007/12/14 15:12:16 $

if nargout == 1,
    hfdesign = fdesign.bandpass('N,Fc1,Fc2', d.Order, d.Fc1, d.Fc2);
    Hd       = butter(hfdesign);
        
    varargout = {Hd};
else
    % Set up design params
    N = get(d,'order');

    if rem(N,2),
        error(generatemsgid('MustBeEven'),'Bandpass designs must be of even order.');
    end

    % Get frequency specs, they have been prenormalized
    Fc1 = get(d,'Fc1');
    Fc2 = get(d,'Fc2');
    Fc = [Fc1, Fc2];

    [z,p,k] = butter(N/2,Fc);
    
    varargout = {z,p,k};

end
