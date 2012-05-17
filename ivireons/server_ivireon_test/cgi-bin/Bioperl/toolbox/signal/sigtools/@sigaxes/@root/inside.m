function hPZ = inside(hPZs, point1, point2)
%INSIDE Returns the roots inside the points.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:10:04 $

hPZ = [];
for i = 1:length(hPZs)
    real = get(hPZs(i), 'Real');
    imag = get(hPZs(i), 'Imaginary');
    
    % See if each of the pz objects fits inside the range.
    if lclinside(real, imag, point1, point2),
        hPZ = union(hPZ, hPZs(i));
    end
    
    if strcmpi(hPZs(i).Conjugate, 'On') && lclinside(real, -imag, point1, point2),
        hPZ = union(hPZ, hPZs(i));
    end
end

% --------------------------------------------------------------
function b = lclinside(real, imag, point1, point2)

b = ((real > point1(1) && real < point2(1)) || (real < point1(1) && real > point2(1))) && ...
    ((imag > point1(2) && imag < point2(2)) || (imag < point1(2) && imag > point2(2)));

% [EOF]
