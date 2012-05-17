function invert(hObj, about)
%INVERT Invert about the imaginary axis
%   INVERT(hOBJ, STR) Invert the current pz about where STR can be
%   'imaginary', 'real', or 'unitcircle'

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2007/12/14 15:19:08 $

error(nargchk(2,2,nargin,'struct'));

hPZ = get(hObj, 'CurrentRoots');

if isempty(hPZ),
    error(generatemsgid('noPoleZeroSelected'), 'No Pole or Zero is selected to invert.');
end

opts = {'imaginary', 'real', 'unitcircle'};
indx = strmatch(about, opts);

if isempty(indx),
    error(generatemsgid('invalidAction'), '''%s'' is not a valid inversion.', about);
end

about = [opts{indx} '_fcn'];

newvalue = feval(about, hPZ);

setvalue(hPZ, newvalue);

% -------------------------------------------------------------------------
function newvalue = imaginary_fcn(hPZ)

newvalue = conj(double(hPZ))*-1;

% -------------------------------------------------------------------------
function newvalue = real_fcn(hPZ)

newvalue = conj(double(hPZ));

% -------------------------------------------------------------------------
function newvalue = unitcircle_fcn(hPZ)

newvalue = invertunitcircle(hPZ);

% [EOF]
