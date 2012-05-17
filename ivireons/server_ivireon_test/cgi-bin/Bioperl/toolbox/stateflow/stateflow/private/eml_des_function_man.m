function [errorStatus, varargout] = eml_des_function_man(chartId,action, varargin)
% This function is the API for the entry point into SimEvents code  
% from Embedded MATLAB codebase for maintaining Embedded MATLAB blocks
% configured for SimEvents use. 
% The input argument chartId is the id of the Embedded MATLAB block which is
% configured for SimEvents, with the property - isDESVariant set to true

%   Copyright 2007-2008 The MathWorks, Inc.

errorStatus = false;
try
     switch action
        case {'update', 'errorcheck', 'help'}
            errorStatus = des_eml_private(chartId,action, varargin);
        case 'title'
            [errorStatus, titleString] = des_eml_private(chartId,action, varargin{1});
            varargout{1} = titleString;
        otherwise
            error('Stateflow:UnexpectedError','Invalid action specified for des_eml_man');
     end
catch
    errorStatus = true;
    errorMsg = ['Error when calling SimEvents.' char(10) 'SimEvents installation is required for using this functionality'];
    error('Stateflow:UnexpectedError',errorMsg);
end