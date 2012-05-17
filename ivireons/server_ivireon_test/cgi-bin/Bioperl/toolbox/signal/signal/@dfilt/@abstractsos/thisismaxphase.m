function f = thisismaxphase(Hd,tol)
%THISISMAXPHASE True if maximum phase.
%   THISISMAXPHASE(Hd) returns 1 if filter Hd is maximum phase, and 0 otherwise.
%
%   THISISMAXPHASE(Hd,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.   
  
%   Author: R. Losada, J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2004/12/26 22:03:23 $
  
if nargin<2; tol=[]; end

[msgid,msg] = warnsv(Hd);
if ~isempty(msg),
    warning(msgid,msg);
end

num = Hd.sosMatrix(:, 1:3);
den = Hd.sosMatrix(:, 4:6);

f = true;

for indx = 1:nsections(Hd)
    f = all([true signalpolyutils('ismaxphase', num(indx, :), den(indx, :), tol)]);
end

% [EOF]
