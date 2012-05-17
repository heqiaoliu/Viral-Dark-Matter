function [out coeffnames variables] = mapcoeffstoports(this,varargin)
%MAPCOEFFSTOPORTS 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/14 04:02:00 $

out = parse_mapcoeffstoports(this,varargin{:});

coeffnames = {'Num','Den'};
idx = find(strcmpi(varargin,'CoeffNames'));
if ~isempty(idx), 
    userdefinednames = varargin{idx+1}; 
    % if user-defined coefficient names are empty, return the default
    % names.
    if ~isempty(userdefinednames)
        coeffnames = varargin{idx+1};
    end
end

if length(coeffnames)~=2,
    error(generatemsgid('InvalidValue'), ...
        'The CoeffNames value must be a cell array containing two strings.');
end

Num = this.privNum.';
Den = this.privDen.';

% Zero padding so that the orders of the coefficients are the same
max_order = order(this)+1;
Num = makemaxorder(Num,max_order);
Den = makemaxorder(Den,max_order);
    
variables{1} = Num;
variables{2} = Den;

%--------------------------------------------------------------------------
function coeffs = makemaxorder(coeffs,maxorder)

currentorder = length(coeffs);
M = abs(maxorder-currentorder);
if currentorder < maxorder
    % If currentorder is less than maxorder, the zero padding is required
    % so that the filter structure is balance.
    coeffs = [coeffs; zeros(M,1)];
elseif currentorder > maxorder
    % If the currentorder (coefficient length) is larger than maxorder,
    % then remove the exceeding coefficients as they are zeros.
    coeffs = coeffs(1:end-M);
end

% [EOF]

