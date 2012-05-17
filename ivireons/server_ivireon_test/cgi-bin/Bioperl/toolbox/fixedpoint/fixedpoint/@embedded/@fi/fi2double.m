function varargout = fi2double(varargin)
%FI2DOUBLE FI to Double
%   [D1,D2,...] = FI2DOUBLE(F1,F2,...) converts fixed-point objects
%   F1, F2, ... to doubles D1, D2, ... respectively.  Any input that
%   is not a FI object is passed through to the output.
%
%   Helper function for converting fixed-point objects to double.

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:12:07 $

varargout = fi2doublecell(varargin{:});
