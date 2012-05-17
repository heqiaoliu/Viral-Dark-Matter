function hWIN = hamming(n, sflag)
%HAMMING Construct a Hamming window object
%   H = SIGWIN.HAMMING(N, S) constructs a Hamming window object with length
%   N and sampling flag S.  If N or S is not specified, they default to 64
%   and 'symmetric' respectively.  The sampling flag can also be
%   'periodic'.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2009/05/23 08:15:52 $

hWIN = sigwin.hamming;
hWIN.Name = 'Hamming';

if nargin > 0, hWIN.Length       = n;     end
if nargin > 1, hWIN.SamplingFlag = sflag; end

% [EOF]
