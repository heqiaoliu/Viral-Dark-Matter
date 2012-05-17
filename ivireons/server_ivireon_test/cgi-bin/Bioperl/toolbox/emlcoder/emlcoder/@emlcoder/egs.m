function this = egs(varargin)
%EGS   Constructor for an explicit-size example object.
%   Syntax:
%     eg = egs(u)
%     eg = egs(u,s)
%     eg = egs(u,s,v)
%
%   Description:
%     eg = egs(u) creates an example object that specifies the size, class,
%     and complexity of a function input. The dimensions of the input are
%     assumed to be variable, with the upper bound taken from the example
%     value u. If the upper bound of a dimension is one, the dimension is
%     assumed to be fixed.
%
%     eg = egs(u,s) creates an example object that specifies the size, 
%     class, and complexity of a function input. The class and complexity 
%     are taken from the example input u. The dimensions of the input are 
%     assumed to be variable, with the upper bound specified by the size
%     vector s. If the upper bound of a dimension is one, the dimension is
%     assumed to be fixed. If the upper bound of a dimension is +Inf, the
%     dimension is assumed to be of unknown upper bound. This also requires
%     that the configuration has dynamic memory allocation enabled.
%
%     eg = egs(u,s,v) creates an example object that specifies the size, 
%     class, and complexity of a function input. The class and complexity
%     are taken from the example input u. The dimensions of the input are 
%     specified by the size vector s. Each dimension may be fixed-size or
%     variable-size, as define by the parameter v, which is a logical
%     vector that specifies which dimensions of the example object 
%     u are to be treated as variable-size. A value of 1 (true) in the 
%     vector indicates that the corresponding dimension is variable-size,
%     with the maximum being specified by the corresponding element of the 
%     size vector s. A value of 0 (false) indicates the corresponding 
%     dimension is fixed-size. 
%
%   Examples:
%     The following example creates an example input, all of whose
%     dimensions are variable size.
%         eg = emlcoder.egs(zeros(3,3))
%
%     The following example creates an example input, all of whose
%     dimensions are variable size. In this example, only the class and
%     complexity is taken from the first parameter, the size being 
%     specified by the second parameter.
%         eg = emlcoder.egs(double(0), [3 3])
%
%     The following example creates an example input, not all of whose
%     dimensions are variable size: the first and third dimensions are
%     fixed-size, while the second is variable-size.
%         eg = emlcoder.egs(double(0), [2 3 4], [false true false])
%
%   See also emlcoder.egc, emlcoder.Example.

%   Copyright 2005-2010 The MathWorks, Inc.

% Call the built-in UDD constructor
this = emlcoder.Example('size',varargin{:});