function c = bitconcat(varargin)
% Embedded MATLAB Library function.
%
% CONCAT Perform concatenation of two fixpt input operands.
%
% Both a and b must be fixed point inputs
% output type cannot be more than 32 bits
% both a and b can be scalars or vectors
% if both are vectors then their size should match

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.13 $ $Date: 2009/12/28 04:10:49 $

% To make sure the number of the input arguments is right

if eml_ambiguous_types
    for i = 1:length(varargin)
        if ~isscalar(varargin{i})
            c = eml_not_const(reshape(zeros(size(varargin{i})), size(varargin{i})));
            return;
        end;
    end
    c = eml_not_const(reshape(zeros(size(varargin{1})), size(varargin{1})));
    return;
end

if (nargin == 1)
    c = bitconcat_unary(varargin{1});
else
    c = bitconcat_nary(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = bitconcat_unary(a)

[maxWL,maxWL_msg] = get_max_bitsize;

n = numel(a);
bitconcat_checkarg(a);
t = eml_typeof(a(n));
wlen = t.WordLength;
eml_assert((wlen * n) <= maxWL, maxWL_msg);

% Concatenate the inputs, using varargout to accumulate the intermediate results.
% The loop counts downwards, so that it creates a series of assignments like this:
%
%      out4 = in4; // Initial assignment, created before the start of the loop.
%      out3 = eml_concat(in3,out4);
%      out2 = eml_concat(in2,out3);
%      out1 = eml_concat(in1,out2);
%
varargout{n} = a(n);
for i = eml.unroll(n-1:-1:1)
    varargout{i} = eml_bitconcat(a(i), varargout{i+1});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = bitconcat_nary(varargin)

[maxWL,maxWL_msg] = get_max_bitsize;

n = nargin;
Fm = eml_fimath(varargin{1});
fmIsLocal = eml_const(eml_fimathislocal(varargin{1}));

bitconcat_checkarg(varargin{n});
varargout{n} = varargin{n};

% Concatenate the inputs, using varargout to accumulate the intermediate results.
% The loop counts downwards, so that it creates a series of assignments like this:
%
%      out4 = in4; // Initial assignment, created before the start of the loop.
%      out3 = eml_concat(in3,out4);
%      out2 = eml_concat(in2,out3);
%      out1 = eml_concat(in1,out2);
%
for i = eml.unroll(n-1:-1:1)
    bitconcat_checkarg(varargin{i});
    outWlen = bitconcat_getwordlength(varargin{i}) + bitconcat_getwordlength(varargout{i+1});
    eml_assert(outWlen <= maxWL, maxWL_msg);
    % Create a binary bitconcat. The most common case is:
    %     varargout{i} = eml_bitconcat(varargin{i}, varargout{i+1});
    % However, either varargin{i} or varargout{i+1} could be non-scalar, so there
    % are four cases to consider.
    if isscalar(varargin{i})
        if isscalar(varargout{i+1})
            varargout{i} = eml_bitconcat(varargin{i}(1), varargout{i+1}(1));
        else
            if eml_const(fmIsLocal)
                varargout{i} = fi(zeros(size(varargout{i+1})), 'numerictype', numerictype(0, outWlen, 0), 'fimath', Fm);
            else
                varargout{i} = fi(zeros(size(varargout{i+1})), 'numerictype', numerictype(0, outWlen, 0));
            end
            for k = 1:eml_numel(varargout{i})
                varargout{i}(k) = eml_bitconcat(varargin{i}(1), varargout{i+1}(k));
            end
        end
    else
        if eml_const(fmIsLocal)
            varargout{i} = fi(zeros(size(varargin{i})), 'numerictype', numerictype(0, outWlen, 0), 'fimath', Fm);
        else
            varargout{i} = fi(zeros(size(varargin{i})), 'numerictype', numerictype(0, outWlen, 0));
        end
        if isscalar(varargout{i+1})
            for k = 1:eml_numel(varargout{i})
                varargout{i}(k) = eml_bitconcat(varargin{i}(k), varargout{i+1}(1));
            end
        else
            eml_lib_assert(eml_scalexp_compatible(varargin{i},varargout{i+1}), 'fixedpoint:fi:dimagree', 'Inputs must have the same size.');
            for k = 1:eml_numel(varargout{i})
                varargout{i}(k) = eml_bitconcat(varargin{i}(k), varargout{i+1}(k));
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wl = bitconcat_getwordlength(x)
    eml_transient;
    y = eml_typeof(x);
    wl = y.WordLength;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bitconcat_checkarg(a)

eml_assert(isfi(a), 'concat input must be of fixed point type.');
eml_assert(isreal(a), 'Inputs must be real.');
if ~isfixed(a)
    % non fi-fixedpoint not supported
    eml_fi_assert_dataTypeNotSupported('BITCONCAT','fixed-point');
end
eml_assert(~eml_isslopebiasscaled(a), 'bitconcat does not support slope-bias scaled fis.');


function [maxWL, maxWL_msg] = get_max_bitsize

maxWL = eml_option('FixedPointWidthLimit');
    
if maxWL == 128
    maxWL_msg = 'output type cannot have more than 128 bits';
elseif maxWL == 32
    maxWL_msg = 'output type cannot have more than 32 bits';
else
    maxWL_msg = 'output type exceeded maximum number of bits';
end
