function [state,r] = eml_rand_mcg16807(method,state,arg3)
%Embedded MATLAB Private Function

%   Usage:
%
%   1. Generate a default uint32 state:
%       state = eml_rand_mcg16807('default_state');
%   2. Compute a new uint32 state from scalar double seed:
%       state = eml_rand_mcg16807('seed_to_state',state,seed);
%   3. Compute the corresponding seed value (double) the uint32 state:
%       [state,seed] = eml_rand_mcg16807('state_to_seed',state);
%   4. Generate a random number r in the interval (0,1) and update state:
%          [state,r] = eml_rand_mcg16807('generate_uniform',state);
%   5. Generate a random normal z using the polar algorithm and update
%      state:
%          [state,r] = eml_rand_mcg16807('generate_normal',state);
%   6. Generate a random (double precision) integer in the interval [1,N]
%      and update state:
%          [state,r] = eml_rand_mcg16807('generate_integer',state,N);
%   7. Generate a random (double precision) integer in the interval [M,N]
%      and update state:
%          [state,r] = eml_rand_mcg16807('generate_integer',state,[M,N]);
%
% 	A uniform random number generator based on the linear congruential
%   method.  The complete theory and practical implementation are given in
%   S.K. Park and K.W. Miller, Random Number Generators: Good Ones are
%   hard to find, Comm. A.C.M, v. 32, n. 10 (October, 1988), p. 1192-1201.
% 	The following code is their Proposed Minimal Standard
% 	Uniform Random Number Generator:
%
% 			seed = (seed * 7^5) modulo (2^31-1).
%
% 	The legal range for seeds is 1 to 2^31-2, inclusive.  Zero
% 	and 2^31-1 are NOT allowed.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_assert(eml_is_const(method) && ischar(method), ...
    'First input must be a constant string.');
MAXSTATE = uint32(2147483646); % 2^31-2
STATE0 = uint32(1144108930); % Seed #6, starting from seed = 1 */
% BIT16 = uint32(32768); % 2^15
if eml_const(strcmp(method,'generate_uniform'))
    % Generate a pseudorandom number and return the new seed.
    eml_assert(nargin == 2,'Expected nargin == 2 for method ''generate_uniform''');
    eml_assert(nargout == 2,'Expected nargout == 2 for method ''generate_uniform''');
    [state,r] = genrandu(state);
elseif eml_const(strcmp(method,'generate_normal'))
    eml_assert(nargin == 2,'Expected nargin == 2 for method ''generate_normal''');
    eml_assert(nargout == 2,'Expected nargout == 2 for method ''generate_normal''');
    [state,r] = genrandn(state);
elseif eml_const(strcmp(method,'generate_integer'))
    eml_assert(nargin == 3,'Expected nargin == 3 for method ''generate_integer''');
    eml_assert(nargout == 2,'Expected nargout == 2 for method ''generate_integer''');
    [state,r] = genrandi(state,arg3);
elseif eml_const(strcmp(method,'default_state'))
    eml_assert(nargin  == 1, 'Expected nargin == 1 for method ''default_state''');
    eml_assert(nargout == 1,'Expected nargout == 1 for method ''default_state''');
    state = STATE0;
elseif eml_const(strcmp(method,'seed_to_state'))
    eml_assert(nargin  == 3, 'Expected nargin == 3 for method ''seed_to_state''');
    eml_assert(nargout == 1,'Expected nargout == 1 for method ''seed_to_state''');
    eml_assert(isscalar(arg3) && isa(arg3,'double'), 'Seed must be a double scalar.');
    state = v4bitinterchange(eml_cast(arg3,'uint32','floor'));
    if state < 1
        state = STATE0;
    elseif state > MAXSTATE
        state = MAXSTATE;
    end
elseif eml_const(strcmp(method,'state_to_seed'))
    eml_assert(nargin  == 2, 'Expected nargin == 2 for method ''state_to_seed''');
    eml_assert(nargout == 2,'Expected nargout == 2 for method ''state_to_seed''');
    r = double(v4bitinterchange(state));
else
    eml_assert(false,'Unrecognized method.');
end

%--------------------------------------------------------------------------

function w = v4bitinterchange(seed)
% Utility function used to convert seed value uint32 <--> double.
eml_must_inline;
% Interchange bits 1-15 and 17-31
r = eml_rshift(seed,uint32(16));
t = eml_bitand(seed,uint32(32768));
% w = ((*pseed - (r << 16) - t) << 16) + t + r;
w = eml_lshift(r,uint32(16));
w = eml_minus(seed,w,'uint32','wrap');
w = eml_minus(w,t,'uint32','wrap');
w = eml_lshift(w,uint32(16));
w = eml_plus(w,t,'uint32','wrap');
w = eml_plus(w,r,'uint32','wrap');

%--------------------------------------------------------------------------

function [state,r] = genrandu(s)
IA	= uint32(16807); % magic multiplier = 7^5
IM	= uint32(2147483647); %	modulus = 2^31-1
IQ	= uint32(127773); %	IM div IA
IR	= uint32(2836); % IM modulo IA
S	= 4.656612875245797e-10; % reciprocal of 2^31-1
hi = eml_rdivide(s,IQ,'uint32','to zero','wrap');
lo = eml_minus(s,eml_times(hi,IQ,'uint32','wrap'),'uint32','wrap'); % mod(s,IQ);
test1 = eml_times(IA,lo,'uint32','wrap');
test2 = eml_times(IR,hi,'uint32','wrap');
if test1 < test2
    state = eml_plus(eml_minus(IM,test2,'uint32','wrap'),test1,'uint32','wrap');
else
    state = eml_minus(test1,test2,'uint32','wrap');
end
r = double(state) * S;

%--------------------------------------------------------------------------

function [state,r] = genrandn(state)
% V4 random normal generator.
while true
    [state,r] = genrandu(state);
    [state,t] = genrandu(state);
    r = 2*r-1;
    t = 2*t-1;
    t = t*t + r*r;
    if t <= 1
        r = r * eml_sqrt(eml_rdivide(-2*eml_log(t),t));
        return
    end
end

%--------------------------------------------------------------------------

function [state,r] = genrandi(state,lowhigh)
% Generate an integer
eml_assert(eml_is_const(size(lowhigh)), 'Range input must be fixed-size.');
eml_assert(isscalar(lowhigh) || eml_numel(lowhigh) == 2, ...
    'Range input must be a scalar or have two elements.');
if isscalar(lowhigh)
    low = 1;
    high = double(lowhigh);
else
    low = double(lowhigh(1));
    high = double(lowhigh(2));
end
[state,r] = genrandu(state);
r = low + floor(r*(high-low+1));

%--------------------------------------------------------------------------
