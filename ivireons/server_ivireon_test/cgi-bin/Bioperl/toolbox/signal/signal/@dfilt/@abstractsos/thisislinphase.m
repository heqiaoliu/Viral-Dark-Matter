function f = thisislinphase(Hd,tol)
%THISISLINPHASE  True for linear phase filter.
%   THISISLINPHASE(Hd) returns 1 if filter Hd is linear phase, and 0 otherwise.
%
%   THISISLINPHASE(Hd,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.

%   Authors: R. Losada, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:52:37 $

if nargin<2; tol=[]; end

[msgid,msg] = warnsv(Hd);
if ~isempty(msg),
    warning(msgid,msg);
end

[b,a] = tf(Hd);
f = signalpolyutils('islinphase',b,a,tol);

% [EOF]
