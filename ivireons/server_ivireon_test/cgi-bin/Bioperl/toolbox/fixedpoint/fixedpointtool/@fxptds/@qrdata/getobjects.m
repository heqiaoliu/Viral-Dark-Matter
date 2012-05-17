function d = getobjects(h)
%GETOBJECTS   returns FixPtSimRanges stored in qrdata.
%   D = GETDATA(H) returns a cell array of structs containing
%   fields and data from FixPtSimRanges stored qrdata 

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:25 $

d = h.Qreport;

% [EOF]