function sub_array = slselsubs(varargin)
%SLSELSUBS Returns the selected elements in a 1xn/nx1 (cell) array A.
%   SUB_ARRAY = SLSELSUBS(A, IDX) select elements from (cell) array A based on
%   the indices IDX
%   SUB_ARRAY = SLSELSUBS(A, IDX, TOEND) select elements from (cell) array A 
%   starting from the one specified by IDX to the end if TOEND is true.
%   Otherwise, it is equivalent to SUB_ARRAY = SLSELSUBS(A, IDX)

%   $Revision: 1.1.6.4 $
%   Copyright 2006-2008 The MathWorks, Inc.

if length(varargin) < 2
    DAStudio.error('Simulink:blocks:SlselsubsNotEnoughArgs');
end

a = varargin{1};
idx = varargin{2};
toend = false;
if length(varargin) > 2
    toend = varargin{3};
end

size_a = size(a);
if length(size_a) ~= 2 || (size_a(1) > 1 && size_a(2) > 1)
    DAStudio.error('Simulink:blocks:SlselsubsFirstArgNotVector');
end

if ~isnumeric(idx) || ~isvector(idx)
    DAStudio.error('Simulink:blocks:SlselsubsSecondArgNotVectorOrScalar');
end

if ~islogical(toend) || ~isscalar(toend)
    DAStudio.error('Simulink:blocks:SlselsubsThirdArgNotLogicScalar');
end

if toend 
    if ~isscalar(idx)
        DAStudio.error('Simulink:blocks:SlselsubsSecondArgNotScalarAsStartingIdx');
    end
    sub_array = a(idx:end);
elseif iscell(a)
    sub_array = a{idx};
else
    sub_array = a(idx);
end
