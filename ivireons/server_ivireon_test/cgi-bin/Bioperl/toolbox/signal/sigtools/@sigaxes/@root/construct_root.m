function construct_root(hObj, re, im)
%CONSTRUCT_ROOT

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:09:57 $

if nargin == 2,
    
    % If there is 1 extra argument it is the complex #.
    set(hObj, 'Real', real(re));
    set(hObj, 'Imaginary', imag(re));
elseif nargin == 3,
    
    % If there are 2 extra arguments each is a component.
    set(hObj, 'Real', re);
    set(hObj, 'Imaginary', im);
end

% [EOF]
