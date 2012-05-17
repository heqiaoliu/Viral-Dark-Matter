function c = bitconcat(varargin)
% Embedded MATLAB Library function.
%
% CONCAT Perform concatenation of fixpt input operands.
%

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.4 $ $Date: 2008/07/18 18:39:26 $

if (nargin == 1)
    c = bitconcat_unary(varargin{1});
else
    c = bitconcat_nary(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = bitconcat_nary(varargin)
if nargin == 1
    c = varargin{1};
else
    c = bitconcat_binary(varargin{1}, bitconcat_nary(varargin{2:nargin}));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = bitconcat_unary(a)
if isscalar(a)
    c = a;
else
    c = bitconcat_unary2(a,1);
end

function c = bitconcat_unary2(a,i)

if i == numel(a) 
   c = a(i);
else
   c = bitconcat_binary(a(i),bitconcat_unary2(a,i+1));
end


function w = bitconcat_binary(u, v)

if eml_ambiguous_types
    if isscalar(u)
        w = eml_not_const(reshape(zeros(size(v)),size(v)));
    else
        w = eml_not_const(reshape(zeros(size(u)),size(u)));
    end
    return;
end

eml_assert(false,['Function ''bitconcat'' is not defined for a first argument of class ',class(u) '.']);

w = 0;

