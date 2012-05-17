function charOut = char(this)
%CHAR   FI to char conversion
%   C = CHAR(F) converts fixed-point object F to a char.
%

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/20 07:11:58 $

charOut = char(double(this));
