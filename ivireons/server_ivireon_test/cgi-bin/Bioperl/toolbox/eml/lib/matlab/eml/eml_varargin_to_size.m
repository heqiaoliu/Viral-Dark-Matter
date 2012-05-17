function sz = eml_varargin_to_size(varargin)
%Embedded MATLAB Private Function

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

eml_assert_valid_size_arg(varargin{:});
if nargin == 0
    % No arguments to inf, nan, rand, etc. returns a scalar.
    sz = [1,1];
elseif nargin == 1
    if isscalar(varargin{1})
        % E.g., ones(3), zeros(5), etc.
        sz = [varargin{1},varargin{1}];
    else
        % E.g. ones([2,3]), zeros([4,5,6]), etc.
        sz = varargin{1};
    end
else
    % E.g., ones(2,3), zeros(4,5,6), etc.
    sz = zeros(1,nargin);
    for k = eml.unroll(1:nargin)
        sz(k) = varargin{k};
    end
end
