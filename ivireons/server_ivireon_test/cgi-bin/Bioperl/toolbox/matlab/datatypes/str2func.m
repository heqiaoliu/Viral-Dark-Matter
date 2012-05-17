%STR2FUNC Construct a function_handle from a function name string.
%    FUNHANDLE = STR2FUNC(S) constructs a function_handle FUNHANDLE to the
%    function named in the string S. The S input must be a scalar string;
%    it cannot be an array or cell array of strings.
%
%    You can create a function handle using either the @function syntax or the
%    STR2FUNC command. You can create an array of function handles from
%    strings by creating the handles individually with STR2FUNC, and then
%    storing these handles in a cellarray.
%
%    Examples:
%
%      To create a function handle from the function name, 'humps':
%
%        fhandle = str2func('humps')
%        fhandle = 
%            @humps
%
%      To call STR2FUNC on a cell array of strings, use the CELLFUN 
%      function. This returns a cell array of function handles:
%
%        fh_array = cellfun(@str2func, {'sin' 'cos' 'tan'}, ...
%                           'UniformOutput', false);
%        fh_array{2}(5)
%        ans =
%           0.2837
%
%    See also FUNCTION_HANDLE, FUNC2STR, FUNCTIONS.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.6.4.5 $ $Date: 2006/04/20 17:47:48 $

