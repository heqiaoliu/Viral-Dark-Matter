function pstruct = eml_parse_parameter_inputs(parms,options,varargin)
%Embedded MATLAB Private Function

%   Processes varargin for parameter name-value pairs and option structure
%   inputs.  The first input, PARMS, must be a struct with field names
%   corresponding to all valid parameters.  The value stored in each field
%   must be a scalar 'uint32'.  The return value PSTRUCT is of the same
%   structure type as PARMS.  The 'uint32' values returned in it are used
%   to look up the corresponding parameter values in varargin{:}.  To
%   retrieve a parameter value, use EML_GET_PARAMETER_VALUE.  For example,
%   to retrieve the parameter AbsTol, you might write
%
%       abstol = eml_get_parameter_value(pstruct.abstol,1e-5,varargin{:})
%
%   where 1e-5 is the default value for AbsTol in case it wasn't specified
%   by the user.
%
%   The options input must be [] or a structure with any of the fields
%       1. CaseSensitivity
%          true  --> case-sensitive name comparisons.
%          false --> case-insensitive name comparisons (the default).
%       2. StructExpand
%          true  --> expand structs as sequences of parameter name-value
%                    pairs (the default).
%          false --> structs not expanded and will generate an error.
%       3. PartialMatching
%          true  --> parameter names match if they match in all the
%                    characters supplied by the user.  There is no
%                    validation of the parameter name set for suitability.
%                    If more than one match is possible, the first is used.
%          false --> parameter names must match in full (the default).
%
%   Note that any parameters may be specified more than once in the inputs.
%   The last instance silently overrides all previous instances.
%
%   The maximum number of parameter names is 65535.
%   The maximum length of VARARGIN{:} is also 65535.
%
%   Example:
%
%   Parse a varargin list for parameters 'tol', 'method', and 'maxits',
%   where 'method' is a required parameter.  Struct input is not
%   permitted, and case-insensitive partial matching is done.
%
%       % Define the parameter names.
%       parms = struct( ...
%           'tol',uint32(0), ...
%           'method',uint32(0), ...
%           'maxits',uint32(0));
%       % Select any non-default parsing options.
%       poptions = struct( ...
%           'PartialMatching',true, ...
%           'StructExpand',false);
%       % Parse the inputs.
%       pstruct = eml_parse_parameter_inputs(parms,poptions,varargin{:});
%       % Retrieve parameter values.
%       tol = eml_get_parameter_value(pstruct.tol,1e-5,varargin{:});
%       assert(logical(pstruct.method),'tbx:foo:mtdreq', ...
%           'METHOD parameter is required and was not supplied.');
%       method = eml_get_parameter_value(pstruct.method,[],varargin{:});
%       maxits = eml_get_parameter_value(pstruct.maxits,1000,varargin{:});

%   Copyright 2009-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_assert(isstruct(parms), 'PARMS input must be a structure.');
[casesens,expstrct,prtmatch] = process_options(options);
n = nargin - 2;
% These are technical limitations of this implementation, so we check them
% here, regardless of whether another limitation may make them impossible
% to violate.
eml_assert(n <= 65535, ...
    'The length of VARARGIN{:} cannot exceed 65535.');
eml_assert(eml_numfields(parms) <= 65535, ...
    'Too many parameter names.  The maximum supported number is 65535.');
% Create and initialize the output structure.
pstruct = eml.nullcopy(parms);
ZERO = zeros('uint32');
for k = eml.unroll(0:eml_numfields(parms)-1)
    eml_assert( ...
        isreal(eml_getfield(parms,eml_getfieldname(parms,k))) && ...
        isscalar(eml_getfield(parms,eml_getfieldname(parms,k))) && ...
        (eml_ambiguous_types || ...
        isa(eml_getfield(parms,eml_getfieldname(parms,k)),'uint32')), ...
        ['The value of each field of the PARMS input structure must ', ...
        'be a real, scalar ''uint32''.']);
    pstruct.(eml_getfieldname(parms,k)) = ZERO;
end
% Parse VARARGIN{:}.
t = eml_const(input_types(varargin{:}));
if n > 0 && t(n) == PARAMETER_NAME
    eml_assert(false, ... eml_assert(n < 1 || t(n) ~= PARAMETER_NAME, ...
        ['Parameter ''' varargin{n} ''' does not have a value.']);
end
for k = eml.unroll(1:n)
    if eml_const(t(k) == PARAMETER_NAME)
        % Find the index of the field varargin{k} in PARMS.
        pidx = field_index(varargin{k},parms,casesens,prtmatch);
        % The parameter value is in varargin{k+1}.  Set the value of
        % the field in PARMS accordingly.
        pstruct.(eml_getfieldname(parms,pidx)) = uint32(k+1);
    elseif expstrct
        if eml_const(t(k) == OPTION_STRUCTURE)
            for fieldidx = eml.unroll(0:eml_numfields(varargin{k})-1)
                % Find the index of the corresponding field in PARMS.
                pidx = field_index( ...
                    eml_getfieldname(varargin{k},fieldidx), ...
                    parms,casesens,prtmatch);
                % The parameter value is in the struct varargin{k} at
                % field index fieldidx.  Set the value of the field
                % in PARMS accordingly.
                pstruct.(eml_getfieldname(parms,pidx)) = ...
                    combine_indices(uint32(k),uint32(fieldidx));
            end
        else
            eml_assert(t(k) == PARAMETER_VALUE, ...
                ['Expected a parameter name or a structure ', ...
                'of parameter names and values.']);
        end
    else
        eml_assert(t(k) == PARAMETER_VALUE, 'Expected a parameter name.');
    end
end

%--------------------------------------------------------------------------

function [casesens,expstrct,prtmatch] = process_options(options)
% Extract parse options from options input structure, supplying default
% values if needed.
eml_assert(eml_is_const(options),['Parse options input must be ', ...
    'constant. Try defining it using struct(...).']);
% Set defaults.
casesens = false;
expstrct = true;
prtmatch = false;
% Read options.
if ~isempty(options)
    eml_assert(isstruct(options), ...
        'Parse options input must be [] or a struct.');
    for k = eml.unroll(0:eml_numfields(options)-1)
        if eml_const(strcmp(eml_getfieldname(options,k), ...
                'CaseSensitivity'))
            eml_assert(isscalar(options.CaseSensitivity) && ...
                islogical(options.CaseSensitivity), ...
                'CaseSensitivity must be true or false.');
            casesens = eml_const(options.CaseSensitivity);
        elseif eml_const(strcmp(eml_getfieldname(options,k), ...
                'StructExpand'))
            eml_assert(isscalar(options.StructExpand) && ...
                islogical(options.StructExpand), ...
                'StructExpand must be true or false.');
            expstrct = eml_const(options.StructExpand);
        elseif eml_const(strcmp(eml_getfieldname(options,k), ...
                'PartialMatching'))
            eml_assert(isscalar(options.PartialMatching) && ...
                islogical(options.PartialMatching), ...
                'PartialMatching must be true or false.');
            prtmatch = eml_const(options.PartialMatching);
        else
            eml_assert(false, ['Options input must be [] or a struct ', ...
                'with fields selected from the list: ', ...
                '''CaseSensitivity'', ''StructExpand'', and ', ...
                '''PartialMatching''.']);
        end
    end
end

%--------------------------------------------------------------------------

function t = input_types(varargin)
% Returns an array indicating the classification of each argument as a
% parameter name, parameter value, option structure, or unrecognized.  The
% return value must be constant folded.
t = zeros(nargin,1,'int8');
isval = false;
for k = eml.unroll(1:nargin)
    if isval
        t(k) = PARAMETER_VALUE;
        isval = false;
    elseif ischar(varargin{k})
        eml_assert(eml_is_const(varargin{k}), ...
            'Parameter names must be constant character strings.');
        t(k) = PARAMETER_NAME;
        isval = true;
    elseif isstruct(varargin{k})
        t(k) = OPTION_STRUCTURE;
    else
        t(k) = UNRECOGNIZED_INPUT;
    end
end

%--------------------------------------------------------------------------

function n = field_index(fname,ostruct,casesens,prtmatch)
% Return the index of field FNAME in structure OSTRUCT.  Asserts if FNAME
% is not a member of OSTRUCT.
eml_must_inline;
eml_prefer_const(fname,casesens,prtmatch);
n = 0;
for j = eml.unroll(0:eml_numfields(ostruct)-1)
    if parameter_names_match(eml_getfieldname(ostruct,j),fname, ...
            casesens,prtmatch)
        n = j;
        return
    end
end
eml_assert(false,['Unrecognized parameter name: ''',fname,'''.']);

%--------------------------------------------------------------------------

function p = parameter_names_match(mstrparm,userparm,casesens,prtmatch)
% Compare parameter names, like strcmp, except modified optionally for case
% insensitivity and/or partial matching.
eml_must_inline;
eml_prefer_const(mstrparm,userparm,casesens,prtmatch);
if eml_const(isempty(userparm))
    p = false;
elseif eml_const(casesens)
    if eml_const(prtmatch)
        p = eml_const(eml_partial_strcmp(mstrparm,userparm));
    else
        p = eml_const(strcmp(mstrparm,userparm));
    end
else
    if eml_const(prtmatch)
        p = eml_const(eml_partial_strcmp( ...
            eml_tolower(mstrparm),eml_tolower(userparm)));
    else
        p = eml_const(strcmp( ...
            eml_tolower(mstrparm),eml_tolower(userparm)));
    end
end

%--------------------------------------------------------------------------

function n = combine_indices(vargidx,stfldidx)
% Returns a 'uint32'.  Stores the struct field index (zero-based) in the
% low bits and the varargin index in the low bits.
% n = (struct_field_ordinal << 16) + vargidx;
n = eml_plus( ...
    eml_lshift(vargidx,int8(16)), ...
    stfldidx, ...
    'uint32','spill');

%--------------------------------------------------------------------------
% Input types

function n = PARAMETER_VALUE
eml_must_inline
n = int8(0);

function n = PARAMETER_NAME
eml_must_inline
n = int8(1);

function n = OPTION_STRUCTURE
eml_must_inline
n = int8(2);

function n = UNRECOGNIZED_INPUT
eml_must_inline
n = int8(-1);

%--------------------------------------------------------------------------
