function [x,t] = rsgenpolycoeffs(varargin)
%RSGENPOLYCOEFFS  Generator polynomial coefficients of Reed-Solomon code.
%   X = RSGENPOLYCOEFFS(...) returns the coefficients of the generator
%   polynomial of the Reed-Solomon code.  The output is identical to 
%   GENPOLY = RSGENPOLY(...); X = GENPOLY.X.
%
%   [X,T] = RSGENPOLYCOEFFS(...) returns T, the error-correction capability
%   of the code.
%
%   See also RSGENPOLY, GF, RSENC, RSDEC.

%    Copyright 2010 The MathWorks, Inc.
[g,t] = rsgenpoly(varargin{:});
x = g.x;

