function obj = loadobj(B)
%LOADOBJ Load filter for timer objects.
%
%   OBJ = LOADOBJ(B) is called by LOAD when a timer object is 
%   loaded from a .MAT file. The return value, OBJ, is subsequently 
%   used by LOAD to populate the workspace.  
%
%   LOADOBJ will be separately invoked for each object in the .MAT file.
%

%    Copyright 2001-2008 The MathWorks, Inc.
%    $Revision: 1.1.4.4 $  $Date: 2010/04/21 21:32:23 $

    % Warn if java is not running.
    if ~usejava('jvm')
        state = warning('backtrace','off');
        warning('MATLAB:timer:nojvm',timererror('MATLAB:timer:nojvm'));
        warning(state);
        return; % not setting obj is OK.
    end

    %The check for a struct is to support old style Timers. (Version 1)
    if (isstruct(B) && isfield(B, 'jobject') && all(isJavaTimer(B.jobject)))
        obj = timer(B);
    elseif isstruct(B) && isfield(B, 'version') && B.version == 3
        if isa(B.TimerFcn, 'cell')
            obj = [];
            for index = 1:length(B.TimerFcn); 
                obj = horzcat(obj,timer);
                instance = subsref(obj, struct('type', '()', 'subs', {{index}}));
                vals = getSettableValues(instance);            
                for i = 1:length(vals)
                    set(instance, vals{i}, B.(vals{i}){index});
                end
            end        
        else
            obj = timer;
            vals = getSettableValues(obj);        
            for i = 1:length(vals)
                set(obj, vals{i}, B.(vals{i}));
            end
        end
    elseif isempty(B)
        obj = timer.empty;
    elseif isvalid(B)  %8a style load.  (version 2)
        obj = timer(B);
        ud = B.ud; %The new MCOS timer sets the userdata property to transient.  We need to load it here.
        if length(obj) == 1
            set(obj, 'Userdata', ud);
        else
            for i = 1:length(obj)
                instance = subsref(obj, struct('type', '()', 'subs', {{i}}));
                set(instance,'Userdata',ud{i});
            end
        end    
    else
        obj = B;
    end

end