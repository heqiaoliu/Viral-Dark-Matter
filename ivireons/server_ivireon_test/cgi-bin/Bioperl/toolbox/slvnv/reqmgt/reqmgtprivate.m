%   Copyright 1994-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $

function varargout = reqmgtprivate(function_name, varargin)
  
    % Temporary support some old-style calls
    switch function_name
        case {'rmi_dialog', 'settings_mgr', 'sync_with_doors'} 
            function_name = ['rmi.' function_name];
    end

   [varargout{1:nargout}] = feval(function_name, varargin{1:end});
