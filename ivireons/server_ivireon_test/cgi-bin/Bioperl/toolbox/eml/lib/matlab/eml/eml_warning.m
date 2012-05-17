function eml_warning(varargin)
%Embedded MATLAB Private Function

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if ~strcmp(eml.target(),'hdl')
    eml_must_not_inline; % For readability in generated code.
end
eml.extrinsic('warning');
warning(varargin{:});
