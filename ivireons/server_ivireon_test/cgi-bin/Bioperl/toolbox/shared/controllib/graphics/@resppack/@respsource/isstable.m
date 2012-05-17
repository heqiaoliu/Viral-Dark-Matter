function boo = isstable(this,idx)
%ISSTABLE   Returns 1 for a stable model.
%
%  TF = ISSTABLE(SRC,N) returns 1 if the N-th model is stable, 
%  0 if it is unstable, and NaN for undetermined.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:37 $

boo = NaN;  % undertermined