function out = openmat(filename)
%OPENMAT   Load data from file and show preview.
%   Helper function for OPEN.
%
%   See OPEN.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2007/10/15 22:53:52 $

try
   out = load(filename);
catch exception;
   throw(exception);
end
