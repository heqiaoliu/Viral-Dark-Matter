function varargout=sl(varargin)
%SL Gateway to Simulink functions.
%   OUTPUT=SL('functionname',ARG1,ARG2,...) runs the function in
%   simulink/private with the given input arguments.
%
%   The functions in simulink/private are unsupported and may change
%   without warning.  Use at your own risk.
%
%   See also SIMULINK.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.3.2.3 $  $Date: 2009/11/13 05:07:41 $

%--------1---------2---------3---------4---------5---------6---------7---------8

[varargout{1:nargout}]=feval(varargin{:});

% if the called function created any variables in this workspace, assign them in
% the workspace of this function's caller
%
% use "sl_feval_yyy" variable names to avoid the chance of overwriting
% variables assigned by the called function
sl_feval_vars = setdiff(who,{'varargin','varargout'});
for sl_feval_idx = 1:length(sl_feval_vars)
    assignin('caller', ...
             sl_feval_vars{sl_feval_idx}, ...
             eval(sl_feval_vars{sl_feval_idx}));
end
