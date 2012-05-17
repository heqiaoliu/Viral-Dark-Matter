function [F,E,A,W] = getNumericSpecs(h,d)
%GETNUMERICSPECS  Get and evaluate design specs from object.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/03/02 10:22:37 $

args = getarguments(h, d);

F = args{1};
E = F;
A = args{2};
W = [args{3}' args{3}']';
W = W(:)';

% [EOF]
