function varargout = pMinMaxTemplate( fcn, varargin )
%pMinMaxTemplate - template for min and max

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:30 $

% Currently only support the element-wise comparison. 
if nargin ~= 3 
    error( sprintf( 'parallel:gpu:%s:Unsupported', fcn ), ...
           'Only the 2 input argument syntax is supported for %s.', upper( fcn ) );
end

% Element-wise comparison can only support 1 output-arg
if nargout > 1
    error( sprintf( 'parallel:gpu:%s:Unsupported', fcn ), ...
           'Only the 1 output argument syntax is supported for %s.', upper( fcn ) );
end

varargout{1} = pElementwiseBinaryOp( fcn, varargin{:} );
