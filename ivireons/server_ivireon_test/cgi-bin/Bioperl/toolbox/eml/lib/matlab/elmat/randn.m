function r = randn(varargin)
%Embedded MATLAB Library Function

%   Limitations:  May not match MATLAB if seeded with negative values.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_prefer_const(varargin);
% Methods.
V5 = uint8(0);
V4 = uint8(1);
persistent method v4_state v5_state
if nargin > 0 && ischar(varargin{1}) && ...
        (nargin > 1 || ~eml_is_float_class(varargin{1}))
    % Handle seed-related tasks.
    getstate = nargin == 1;
    eml_assert(nargin <= 2, 'Too many input arguments.');
    eml_assert(getstate || nargout == 0, 'Too many output arguments.');
    eml_assert(getstate || isa(varargin{2},'numeric'), ...
        'Inputs must be numeric.');
    eml_assert(eml_is_const(varargin{1}), ...
        'Command option must be a constant string.');
    % Return state information or set generator and state.
    if strcmp(varargin{1},'state')
        if getstate
            % Return V5 state.
            if isempty(v5_state)
                v5_state = eml_const(eml_rand_shr3cong('default_state'));
            end
            r = double(v5_state);
        else % setstate
            % Select V5 method and set state from varargin{2}.
            method = V5;
            eml_assert(eml_is_const(size(varargin{2})), ...
                'Seed or state input must be fixed-size.');
            if isscalar(varargin{2})
                eml_assert(isa(varargin{2},'double'), ...
                    'Seed input must be a scalar double.');
                v5_state = eml_rand_shr3cong('default_state');
                v5_state = eml_rand_shr3cong('seed_to_state',v5_state,varargin{2});
            else
                eml_assert(isequal(size(varargin{2}),[2,1]) && ...
                    isa(varargin{2},'double'), ...
                    'State must be a double scalar or the output of RANDN(''state'').');
                v5_state = uint32(varargin{2});
            end
        end
    elseif strcmp(varargin{1},'seed')
        if isempty(v4_state)
            v4_state = eml_const(eml_rand_mcg16807('default_state'));
        end
        if getstate
            % Return V4 seed value in r.
            [v4_state,r] = eml_rand_mcg16807('state_to_seed',v4_state);
        else % setstate
            % Select V4 method and compute new v4_state value from s.
            method = V4;
            v4_state = eml_rand_mcg16807('seed_to_state',v4_state,varargin{2});
        end
    else
        eml_assert(false,'Unknown command option.');
    end
    return
end
% Preallocate return value.
if nargin > 0 && ischar(varargin{nargin})
    eml_assert(eml_is_const(varargin{nargin}), ...
        'Trailing output class argument must be a constant string.');
    eml_assert(eml_is_float_class(varargin{nargin}), ...
        'Output class must be ''single'' or ''double''.');
    r = eml.nullcopy(eml_expand(zeros(varargin{nargin}),varargin{1:nargin-1}));
else
    r = eml.nullcopy(eml_expand(0,varargin{:}));
end
% Generate random numbers.
if isempty(method)
    method = V5;
end
if method == V5
    if isempty(v5_state)
        v5_state = eml_const(eml_rand_shr3cong('default_state'));
    end
    for k = 1:eml_numel(r)
        [v5_state,r(k)] = eml_rand_shr3cong('generate_normal',v5_state);
    end
else % if method == V4
    if isempty(v4_state)
        v4_state = eml_const(eml_rand_mcg16807('default_state'));
    end
    for k = 1:eml_numel(r)
        [v4_state,r(k)] = eml_rand_mcg16807('generate_normal',v4_state);
    end
end
