function output = hdl_target_methods(method, targetId, varargin)
% output = hdl_target_methods(method, targetId, varargin)
% Target function for hdl targets.  See target_methods.m

%   Copyright 1995-2010 The MathWorks, Inc.

output = feval(method,targetId,varargin{:});

function output = codeflags(targetId,varargin)
    persistent flags
    
    if(isempty(flags))
        flag.values = []; % For enum only
        
        flag.name = 'comments';
        flag.type = 'boolean';
        flag.description = 'User Comments in generated code';
        flag.defaultValue = 1;
        flags = flag;

        for i=1:length(flags)
            flags(i).visible = 'on';
            flags(i).enable = 'on';
        end
    end
    
    flags = target_code_flags('fill',targetId,flags);
    output = flags;
