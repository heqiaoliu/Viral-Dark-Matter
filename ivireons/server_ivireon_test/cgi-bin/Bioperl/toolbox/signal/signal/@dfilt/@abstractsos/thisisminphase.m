function f = thisisminphase(Hd,tol)
%THISISMINPHASE True if minimum phase.
%   THISISMINPHASE(Hd) returns 1 if filter Hd is minimum phase, and 0 otherwise.
%
%   THISISMINPHASE(Hd,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.   
  
%   Author: R. Losada, J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2004/12/26 22:03:24 $
  
if nargin<2; tol=[]; end

[msgid,msg] = warnsv(Hd);
if ~isempty(msg),
    warning(msgid,msg);
end

num = Hd.sosMatrix(:, 1:3);
den = Hd.sosMatrix(:, 4:6);

f = true;

% Loop over each section and check if it is minimumphase.
for indx = 1:nsections(Hd)
    if ~(signalpolyutils('isminphase', num(indx, :), tol) && ...
            signalpolyutils('isstable', den(indx, :)));
        f = false;
        return;
    end
end

% [EOF]
