function h = findobjhelper( varargin )

%   Copyright 2009-2010 The MathWorks, Inc.

    allowHVHandles = true;

    nin = nargin;
    rootHandleVis = builtin( 'get', 0, 'ShowHiddenHandles' );
    
    % See if 'flat' keyword is present 
    hasflat = false;
    if (nin > 1) 
        if strcmp( varargin{2}, 'flat' ) % Does the 'flat' keyword exist
            hasflat = true;
        end
    end
    
    if nin == 0
        if feature('HgUsingMatlabClasses')
            h = findobjinternal( 0, '-function', @findobjfilter );  
        else
            h = findobjinternal(0);
        end
    else
        if feature('HgUsingMatlabClasses')
            handles = varargin{1};
            args = varargin(2:end);
            if ischar( varargin{1} )
                handles = handle(0);
                args = varargin(1:end);
            end
                
            if hasflat
                pargs = {'-depth', 0};
                sargs = args(2:end);
                args = {pargs{:} sargs{:}};
            end
            
            if allowHVHandles
                % If HandleVisibility of any handles is 'off', set it to 'on'
                % for the duration of the findobj call
                HV = get(handles,'HandleVisibility');
                set(handles,'HandleVisibility','on');
            end
            
            h = findobjinternal( handles, args, '-function', @findobjfilter );
            
            if allowHVHandles
                len = length(handles);
                % NOTE: This next block should work with a single line of code.
                % Look at the hg2utils.HGHandle.set() method to see if cells are handled
                % correctly.
                if len > 1
                    for i=1:len
                        set(handles(i),'HandleVisibility',HV{i});
    %                     set(handles,'HandleVisibility',HV);
                    end
                else
                    set(handles, 'HandleVisibility', HV);
                end
            end
        else
            h = findobjinternal( varargin{:} );
        end
    end
    
    function b = findobjfilter( obj, h ) 
        % test for 'internal' objects
        in = get(obj, 'Internal');
        
        % test for handle visibility
        hv = get(obj, 'HandleVisibility');
        isInCallback = ~isempty(get(0, 'CallbackObject'));
        if (strcmp(rootHandleVis, 'on' ) || ...
            (strcmp(hv, 'callback') && isInCallback))
            hv = 'on';
        end
            
        b = strcmp( hv, 'on' ) && ~in; 
    end

% The MCOS findobj method return an empty array of type of handle class
% The following handling of empty conforms to existing hg expectations.
    if isempty(h)
        h = ones(0,1);
    end
end
