function eml_error(varargin)
%Embedded MATLAB Private Function

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
if ~strcmp(eml.target(),'hdl')
    eml_must_not_inline; % For readability in the generated code.
end
eml.extrinsic('error');
error(varargin{:});
