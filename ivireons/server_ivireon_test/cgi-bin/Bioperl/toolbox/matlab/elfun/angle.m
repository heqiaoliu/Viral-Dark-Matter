function p = angle(h)
%ANGLE  Phase angle.
%   ANGLE(H) returns the phase angles, in radians, of a matrix with
%   complex elements.  
%
%   Class support for input X:
%      float: double, single
%
%   See also ABS, UNWRAP.

%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 5.7.4.2 $  $Date: 2010/04/21 21:31:19 $

p = atan2(imag(h), real(h));

