function has = minanalogspecs(h,hs)
%MINANALOGSPECS   Compute an analog specifications object from a
%minimum-order digital specifications object.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:19:20 $

% Compute analog response type object
hasmin = analogresp(hs);

% Convert from minimum order to specify order
has = tospecifyord(h,hasmin);

% [EOF]
