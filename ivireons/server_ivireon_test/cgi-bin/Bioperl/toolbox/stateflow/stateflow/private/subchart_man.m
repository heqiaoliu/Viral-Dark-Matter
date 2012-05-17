function varargout = subchart_man(cmdName, varargin)
    % For Mathworks internal use only
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    
    try

        varargout = cell(nargout, 1);
        
        switch (cmdName)
            case {'chartGetParentUdi'}
                [varargout{:}] = Stateflow.SLINSF.SubchartMan.(cmdName)(varargin{:});
                return
        end
        
        mc = ?Stateflow.SLINSF.SubchartMan;
        method = [];
        for i=1:length(mc.Methods)
            if strcmp(mc.Methods{i}.Name, cmdName)
                method = mc.Methods{i};
                break;
            end
        end
        if ~isempty(method) && isa(method, 'meta.method')
            if method.Static
                [varargout{:}] = Stateflow.SLINSF.SubchartMan.(cmdName)(varargin{:});
            else
                obj = Stateflow.SLINSF.SubchartMan(varargin{1});
                [varargout{:}] = obj.(cmdName)(varargin{2:end});
            end
        end
    catch ME
        % Since subchart_man gets called from within C++, sometimes error
        % messages get suppressed and eaten up by assertions, preventing
        % the errors from being displayed on the command window. By
        % displaying the error here, we ensure that we always see the
        % MATLAB error on the command window.
        disp('Internal Error: Caught exception in subchart_man! Original error message follows:')
        disp(ME.getReport);
        rethrow(ME);
    end
end
