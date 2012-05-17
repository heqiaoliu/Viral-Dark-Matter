function y = eml_feval(funstr, varargin)
% Embedded MATLAB Library function.
%
% EML_FEVAL function evaluation
%

%   Copyright 2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.1 $  $Date: 2009/12/07 20:41:45 $

eml_assert(eml_is_const(funstr), 'eml_feval invalid function name argument');

switch funstr
    case 'eml_lshift'
        y = eml_lshift(varargin{:});
    case 'eml_rshift'
        y = eml_rshift(varargin{:});
    case 'eml_rshift_logical'
        y = eml_rshift_logical(varargin{:});
    otherwise
        eml_assert(false, ['Unsupported eml_feval funstr argument: ' funstr]);
end
