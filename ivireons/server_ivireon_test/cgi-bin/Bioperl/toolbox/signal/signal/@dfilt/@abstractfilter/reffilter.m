function Hd = reffilter(this)
%REFFILTER   Returns the double representation of the filter object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:43:46 $

for indx = 1:length(this)
    
    % Create a new object of the same class.
    Hd(indx) = feval(class(this(indx)));
    
    % Sync up the coefficients.
    rv = refvals(this(indx));
    
    % Get coefficient names
    cn = coefficientnames(this(indx));
    
    % Set public properties with reference values
    for n = 1:length(rv),
        set(Hd(indx),cn{n},rv{n});
    end

    setfdesign(Hd(indx), getfdesign(this(indx))); % Carry over fdesign obj
    setfmethod(Hd(indx), getfmethod(this(indx)));
end

% [EOF]
