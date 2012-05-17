function varsize(varargin)
%EML.VARSIZE Declare variable-size data
% 
% Syntax
%
% EML.VARSIZE('VAR1', 'VAR2', ...)
% EML.VARSIZE('VAR1', 'VAR2', ..., UBOUND)
% EML.VARSIZE('VAR1', 'VAR2', ..., UBOUND, DIMS)
% EML.VARSIZE('VAR1', 'VAR2', ..., [], DIMS)
%
% Description
% 
% eml.varsize('var1', 'var2', ...) declares one or more variables as 
% variable-size data, allowing subsequent assignments to extend their 
% size. Each 'varn' must be a quoted string that represents a variable, 
% or structure field. If the structure field is a structure array, 
% use colon (:) as the index expression, indicating that all elements 
% of the array are variable sized. 
%
% For example, the expression eml.varsize('data(:).A') declares that 
% the field A inside each element of data is variable sized.
% 
% eml.varsize('var1', 'var2', ..., ubound) declares one or more 
% variables as variable-size data with an explicit upper bound specified 
% in ubound. The argument ubound must be a constant, integer-valued 
% vector of upper bound sizes for every dimension of each 'varn'. 
% If you specify more than one 'varn', each variable must have the same 
% number of dimensions.
% 
% eml.varsize('var1', 'var2', ..., ubound, dims) declares one or more 
% variables as variable-sized with an explicit upper bound and a mix of 
% fixed and varying dimensions specified in dims. The argument dims is 
% a logical vector, or double vector containing only zeros and ones. 
% Dimensions that correspond to zeros or false in dims have fixed size; 
% dimensions that correspond to ones or true vary in size. If you 
% specify more than one variable, each fixed dimension must have the 
% same value across all 'varn'.
% 
% eml.varsize('var1', 'var2', ..., [], dims) declares one or more 
% variables as variable-sized with a mix of fixed and varying dimensions. 
% The empty vector [] means that you do not specify an explicit upper bound.
% 
% When you do not specify ubound, Embedded MATLAB computes the upper bound 
% for each 'varn'.
% 
% When you do not specify dims, Embedded MATLAB assumes that all dimensions 
% are variable except the singleton ones. A singleton dimension is any 
% dimension for which size(A,dim) = 1.
% 
% You must add the eml.varsize declaration before each 'varn' is used (read). 
% You may add the declaration before the first assignment to each 'varn'.
% 
% eml.varsize cannot be applied to global variables. When generating code 
% with emlc/emlmex, use an emlcoder.egs object inside the '-global' switch
% to define variable-sized global data.
% 
% This function has no effect in MATLAB code; it applies to the Embedded 
% MATLAB subset only.
%
% Example
% 
% Develop a simple stack that varies in size up to 32 elements as you push 
% and pop data at runtime.
% 
%
%   function test_stack %#eml
%       % The directive %#eml declares the function
%       % to be Embedded MATLAB compliant
%       stack('init', 32);
%       for i = 1 : 20
%           stack('push', i);
%       end
%       for i = 1 : 10
%           value = stack('pop');
%           % Display popped value.
%           value
%       end
%   end
%
%   function y = stack(command, varargin)
%       persistent data;
%       if isempty(data)
%           data = ones(1,0);
%       end
%       y = 0;
%       switch (command)
%       case {'init'}
%           eml.varsize('data', [1, varargin{1}], [0 1]);
%           data = ones(1,0);
%       case {'pop'}
%           y = data(1);
%           data = data(2:size(data, 2));
%       case {'push'}
%           data = [varargin{1}, data];
%       otherwise
%           assert(false, ['Wrong command: ', command]);
%       end
%   end
%
% The variable 'data' is the stack. 
% The statement eml.varsize('data', [1, varargin{1}], [0 1]) declares that:
% * Data 'i' s a row vector
% * Its first dimension has a fixed size
% * Its second dimension can grow to an upper bound of 32
%
% Copyright 2009-2010 The MathWorks, Inc.
