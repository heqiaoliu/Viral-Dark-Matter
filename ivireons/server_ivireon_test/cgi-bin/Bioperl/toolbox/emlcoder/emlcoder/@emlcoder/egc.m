function this = egc(varargin)
%EGC   Constructor for an example constant object.
%   Syntax:
%     eg = egc(v)
%
%   Description:
%     eg = egc(v) creates an example object that specifies the value of a 
%     function input that is to be treated as a constant.
%
%   Examples:
%     eg = emlcoder.egc(42)
%
%   See also emlcoder.egs, emlcoder.Example.

%   Copyright 2005-2009 The MathWorks, Inc.

% Call the built-in UDD constructor
this = emlcoder.Example('const',varargin{:});