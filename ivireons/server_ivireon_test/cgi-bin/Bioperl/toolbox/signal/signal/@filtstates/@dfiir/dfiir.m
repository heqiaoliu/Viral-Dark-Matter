function h = dfiir(numstates,denstates)
%DFIIR   Direct-form IIR filter states.
%   H = FILTSTATES.DFIIR constructs a default direct-form IIR filter states
%   object.
%
%   H = FILTSTATES.DFIIR(NUMSTATES,DENSTATES) constructs an object and sets
%   its 'Numerator' and 'Denominator' properties to NUMSTATES and DENSTATES
%   respectively.  
%
%   Notice that the Filter Design Toolbox, along with the Fixed-Point
%   Toolbox, enables single precision floating-point and fixed-point
%   support for the Numerator and Denominator states.
%
%   Example #1, construct the default object
%   h = filtstates.dfiir
%
%   Example #2, construct an object with Numerator and Denominator states
%   as vectors of zeros.
%   h = filtstates.dfiir(zeros(4,1),zeros(4,1));
%
%   See also FILTSTATES.DOUBLE, DFILT.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:54 $

error(nargchk(0, 2, nargin,'struct'));

h = filtstates.dfiir;

if nargin>=1
  h.Numerator = numstates;
end
if nargin>=2
  h.Denominator = denstates;
end

% [EOF]
