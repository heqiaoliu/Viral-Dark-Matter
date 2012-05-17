function r = rand(varargin)
%Embedded MATLAB Library Function
%
%   Limitations:
%   1. Does not support the swb2712 (rand(''state'')) generator.
%   2. May not match MATLAB if seeded with negative values.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml
eml.inline('never');
eml_prefer_const(varargin);
% Methods.
% V5 = uint8(0);
V4 = uint8(1);
TWISTER = uint8(2);
persistent method v4_state twister_state
if nargin > 0 && ischar(varargin{1}) && ...
        (nargin > 1 || ~eml_is_float_class(varargin{1}))
    % Handle seed-related tasks and return.
    getstate = nargin == 1;
    eml_assert(nargin <= 2, 'Too many input arguments.');
    eml_assert(getstate || nargout == 0, 'Too many output arguments.');
    eml_assert(getstate || isa(varargin{2},'numeric'), ...
        'Inputs must be numeric.');
    eml_assert(eml_is_const(varargin{1}), ...
        'Command option must be a constant string.');
    eml_assert(~strcmp(varargin{1},'state'), ...
        'The swb2712 (''state'') uniform random number generator is not supported in Embedded MATLAB.');
    if strcmp(varargin{1},'twister');
        if getstate
            % Return state vector in r.
            if isempty(twister_state)
                twister_state = eml_rand_mt19937ar('default_state');
            end
            r = twister_state;
        else % setstate
            % Select TWISTER method and compute new state vector from varargin{2}.
            eml_assert(eml_is_const(size(varargin{2})),'State must be fixed-size.');
            if eml_const(isscalar(varargin{2}))
                if isempty(twister_state)
                    twister_state = eml_rand_mt19937ar('preallocate_state');
                end
                twister_state = eml_rand_mt19937ar('seed_to_state', ...
                    twister_state,varargin{2});
            else
                % [~,isvalid] = eml_rand_mt19937ar('validate_state',varargin{2});
                % eml_assert(eml_is_const(isvalid),'Should have been constant.');
                % eml_assert(isvalid,'State must be a scalar double or the output of RAND(''twister'').');
                eml_assert((eml_ambiguous_types || isa(varargin{2},'uint32')) && ...
                    isequal(size(varargin{2}),size(eml_rand_mt19937ar('preallocate_state'))), ...
                    'State must be a scalar double or the output of RAND(''twister'').');
                twister_state = varargin{2};
            end
            method = TWISTER;
        end
    elseif strcmp(varargin{1},'seed')
        if isempty(v4_state)
            v4_state = eml_const(eml_rand_mcg16807('default_state'));
        end
        if getstate
            % Return seed value in r.
            [v4_state,r] = eml_rand_mcg16807('state_to_seed',v4_state);
        else % setstate
            % Select V4 method and compute new seed value from varargin{2}.
            v4_state = eml_rand_mcg16807('seed_to_state',v4_state,varargin{2});
            method = V4;
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
    method = TWISTER;
end
if method == TWISTER
    if isempty(twister_state)
        twister_state = eml_rand_mt19937ar('default_state');
    end
    for k = 1:eml_numel(r)
        [twister_state,r(k)] = eml_rand_mt19937ar('generate_uniform',twister_state);
    end
else % if method == V4
    if isempty(v4_state)
        v4_state = eml_const(eml_rand_mcg16807('default_state'));
    end
    for k = 1:eml_numel(r)
        [v4_state,r(k)] = eml_rand_mcg16807('generate_uniform',v4_state);
    end
end
