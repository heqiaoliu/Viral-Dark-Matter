function msg = parse_inputs(Hd, varargin)
%PARSE_INPUTS Parse the inputs of the constructor.
%   Inputs can be either an sos matrix and a ScaleValues vector or a series
%   of second order numerator and denominators followed by a ScaleValues
%   vector. In either case, the ScaleValues vector  is always optional.


%   Author: V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $

msg = [];

if nargin < 2,
    sosm = [1 0 0 1 0 0];
    ScaleValues = [];
    soscase(Hd,sosm,ScaleValues);
else
    if size(varargin{1},2)==6,
        % SOS matrix specified
        msg = soscase(Hd,varargin{:});
        if ~isempty(msg), return, end
    else
        % b1,a1,b2,a2,...,g
        [sosm,g,msg] = formsos(varargin{:});
        if ~isempty(msg), return, end
        msg = soscase(Hd,sosm,g);
        if ~isempty(msg), return, end
    end
end

%---------------------------------------------------------
function msg = soscase(Hd,varargin)
%SOSCASE Input is SOS matrix.

msg = [];
error(nargchk(1,3,nargin,'struct'));
sosm = varargin{1};
nsections = size(sosm,1);
ScaleValues = [];
if nargin > 2,
    ScaleValues = varargin{2};
    if length(ScaleValues)>nsections + 1,
        msg = 'Too many scale values specified.';
        return
    end
end

set(Hd,'sosmatrix',sosm,'ScaleValues',ScaleValues);

%-----------------------------------------------------------
function [sosm,ScaleValues,msg] = formsos(varargin)
% FORM SOS matrix

sosm = [];
ScaleValues = [];
msg = [];

isscaled = (rem(nargin, 2) == 1);
if isscaled,
    % Odd number of inputs: last input = ScaleValues
    ScaleValues = varargin{end};
    lim = (nargin - 1)/2;
else

    lim = nargin/2;
end

% Preallocate sos matrix
sosm = zeros(lim,6);
for k=1:lim, 
    num = varargin{2*k-1};
    den = varargin{2*k};
    [num,msg] = checknumorden(num);
    if ~isempty(msg), return, end
    [den,msg] = checknumorden(den);
    if ~isempty(msg), return, end
    sosm(k,1:3) = num;
    sosm(k,4:6) = den;
end
%---------------------------------------------------------------
function [pol,msg] = checknumorden(pol)
% Check numerator or denominator for valid order

msg = [];
if length(pol) > 3,
    msg = 'Numerator and denominator polynomials must be of length 3 or less.';
    return
end

% Make sure polynomials are rows
pol = pol(:).';

pol = [pol, zeros(1,3-length(pol))];
