function [errid,errmsg] = eml_validate_toolbox_inputs(function_name, n_outputs, n_variable_inputs, varargin)
%Embedded MATLAB Library Function
%
% This function is undocumented and unsupported.  It is needed for the
% correct functioning of your installation.
    
% Call a toolbox function with the signature indicated by the input arguments
% and return any error ids and error messages that the builtin function throws.  
%
% Return an error id and error message if any of the inputs are not double.
%
% For examples of use, see:
%   toolbox/signal/signal/private/eml_dct_validate_inputs.m
% and functions in 
%   toolbox/signal/eml.

% Copyright 2009 The MathWorks, Inc.
 
errid  = '';
errmsg = '';
variable_input = cell(n_variable_inputs,1);
const_input = varargin(3*n_variable_inputs+1:end);

for i=1:3:3*n_variable_inputs
    sz = varargin{i};
    cls =  varargin{i+1};
    is_real =  varargin{i+2};
    if ~isequal(cls,'double')
        errid = [function_name,':inputNotDouble'];
        errmsg = 'Input must be a double-precision matrix.';
        return;
    end
    if is_real
        variable_input{i} = zeros(sz,cls);
    else
        variable_input{i} = complex(zeros(sz,cls),zeros(sz,cls));
    end
end
try
    if n_outputs > 0
        % May be able to use this case always.  Check to see what it does if n_outputs==0.
        % This case is useful in case there are too many (or rarely too few) output arguments.
        args_out = cell(1,n_outputs);
        [args_out{1:end}] = feval(function_name, variable_input{:}, const_input{:}); %#ok
    else
        % Should this suppress plotting, like freqz would do?
        feval(function_name, variable_input{:}, const_input{:});
    end
catch me
    errid  = me.identifier;
    errmsg = me.message;
end

