function has = analogspecsword(h,hs)
%ANALOGSPECSWORD   Compute an analog specifications object from a
%digital specifications object with filter order.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:19:17 $

% Compute analog response type object
has = analogresp(hs);

% [EOF]
