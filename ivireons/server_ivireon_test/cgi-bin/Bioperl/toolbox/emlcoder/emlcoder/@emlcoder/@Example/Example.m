function this = Example(varargin)
%EXAMPLE   Constructor for an Example object.
%   Syntax:
%     eg = Example('const', v)
%     eg = Example('size', u,s,v)
%
%   Description:
%     eg = Example('const', v) creates an example object that specifies the
%     value of a function input that is to be treated as a constant.
%
%     eg = Example('size', u,s,v) creates an example object that specifies  
%     the size, class, and complexity of a function input. The class and 
%     complexity are taken from the example input u. The dimensions of the  
%     input are specified by the size vector s. If an element of the size
%     vector is +Inf then that dimension is specified as being of unknown
%     size. Each dimension may be fixed-size or variable-size, as defined by
%     the parameter v, which is a  logical vector that specifies which
%     dimensions of the example object u are to be treated as variable-size. 
%
%   Example:
%     eg = emlcoder.Example('const',42)
%
%   See also emlcoder.egc, emlcoder.egs, emlcoder.CompilerOptions, 
%   emlcoder.HardwareImplementation, emlcoder.MEXConfig, 
%   emlcoder.RTWConfig.

%   Copyright 2005-2010 The MathWorks, Inc.

% Built-in UDD constructor
this = emlcoder.Example(varargin{:});