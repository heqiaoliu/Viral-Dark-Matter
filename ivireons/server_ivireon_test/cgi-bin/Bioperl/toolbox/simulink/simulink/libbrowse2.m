function varargout = libbrowse2(varargin)
%LIBBROWSE2  Launches the Simulink Library Browser, reincarnated.
%   This Library Browser uses a repository of stored icons, block
%   descriptions, and other library information.

%   Copyright 2007-2010 The MathWorks, Inc.

% Simulink must be loaded before the library browser
load_simulink;

persistent lb;

try
    % We must lock this file into memory to preserve LB handle.
    mlock;  
    
    SLPerfTools.Tracer.logSLStartupData('LibraryBrowser2', true);
    if(nargin == 0)
	    load_system('simulink');		% backwards compatibility (g457005)
        lb = LibraryBrowser.StandaloneBrowser;
        lb.show;  
    elseif(nargin == 1)
        switch lower(varargin{1})
            case 'open',
	            load_system('simulink');% backwards compatibility (g457005)
                lb = LibraryBrowser.StandaloneBrowser;
                lb.show;
            case 'close',
                if(isa(lb,'LibraryBrowser.StandaloneBrowser'))
                    lb.hide();
                else
                    disp('Error: Simulink Library Browser is not open');
                    beep;
                end
            otherwise,
                disp('Error: Invalid argument provided to ''simulink''');
                beep;        
        end
    end
    SLPerfTools.Tracer.logSLStartupData('LibraryBrowser2', false);
catch E%#ok
    beep;
    SLPerfTools.Tracer.logSLStartupData('LibraryBrowser2', false);
    disp('Error: The Simulink Library Browser failed to initialize.');
    E.rethrow;
end

% Return the UDD handle if nargout > 0
if(nargout > 0)
    varargout{1} = lb;
end


%[EOF: libbrowse2.m]


