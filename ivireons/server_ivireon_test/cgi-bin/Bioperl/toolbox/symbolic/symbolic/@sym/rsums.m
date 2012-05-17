function rsums(f,varargin)
%RSUMS  Interactive evaluation of Riemann sums.
%   RSUMS(F) approximates the integral of F from 0 to 1 by Riemann sums.
%   RSUMS(F,A,B) approximates the integral of F from A to B.
%   F is a scalar sym representing a function of exactly one variable.

%   Copyright 1993-2010 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2010/02/09 00:31:45 $

rsums(char(f),varargin{:});
