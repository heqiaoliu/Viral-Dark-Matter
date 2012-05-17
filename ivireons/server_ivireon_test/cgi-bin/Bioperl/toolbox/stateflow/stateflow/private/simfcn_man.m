function varargout = simfcn_man(cmdName, varargin)
    % Main switchyard for handling Simulink function callbacks.

    %   Copyright 2007-2009 The MathWorks, Inc.

    try
        varargout = cell(nargout, 1);

        % g533394: We special case a few of the static methods which get
        % called a lot (even for models without any SL functions) in order
        % to get a bit of a performance boost during load time.
        switch (cmdName)
            case {'chartNeedsToasting', ...
                  'redoInnerLayout', ...
                  'createChartLocalDSMs', ...
                  'getParentUDI'}
                [varargout{:}] = Stateflow.SLINSF.SimfcnMan.(cmdName)(varargin{:});
                return
        end

        mc = ?Stateflow.SLINSF.SimfcnMan;
        method = [];
        for i=1:length(mc.Methods)
            if strcmp(mc.Methods{i}.Name, cmdName)
                method = mc.Methods{i};
                break;
            end
        end
        if ~isempty(method)
            if method.Static
                [varargout{:}] = Stateflow.SLINSF.SimfcnMan.(cmdName)(varargin{:});
            else
                obj = Stateflow.SLINSF.SimfcnMan(varargin{1});
                [varargout{:}] = obj.(cmdName)(varargin{2:end});
            end
        end
    catch ME
        % Since simfcn_man gets called from within C++, sometimes error
        % messages get suppressed and eaten up by assertions, preventing
        % the errors from being displayed on the command window. By
        % displaying the error here, we ensure that we always see the
        % MATLAB error on the command window.
        disp('Internal Error: Caught exception in simfcn_man! Original error message follows:')
        disp(ME.getReport);
        rethrow(ME);
    end    
