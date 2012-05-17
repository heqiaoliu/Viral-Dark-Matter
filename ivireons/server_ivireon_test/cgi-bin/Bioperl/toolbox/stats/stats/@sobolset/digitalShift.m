function X = digitalShift(obj, X)
%DIGITALSHIFT Apply a digital shift to points.
%   DIGITALSHIFT(P,X) applies a digital shift to the points in X if there
%   is one defined in the point set P.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:16 $

DS = obj.DigitalShifts;
if ~isempty(DS)
    X = matrixBitXor(X, DS);
end
