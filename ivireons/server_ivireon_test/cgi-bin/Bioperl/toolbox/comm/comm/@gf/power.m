function z = power(x,y,varargin)
%POWER  Element-by-element exponentiation .^ of GF array.
%   Z = X.^Y denotes element-by-element powers.  X and Y
%   must have the same dimensions unless one is a scalar. 
%   X is a GF array, and Y must be double or integer.  
%   If Y is double, only its integer portion is retained.
%   The result Z is a GF array in the same field as X.

%    Copyright 1996-2009 The MathWorks, Inc.
%    $Revision: 1.5.2.3 $  $Date: 2009/05/23 07:49:22 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

if isa(y,'gf'), 
    error('comm:gf_power:yNotgf','x.^y not defined for y in GF(2^M).') 
end

if(~isfinite(y))
    error('comm:gf_power:Infinitely','Exponentiation by Inf or NaN not defined for Galois Fields');
end

% expand scalar to match size of other argument
if numel(x.x)==1
    x.x = x.x(ones(size(y)));
elseif numel(y)==1
    y = y(ones(size(x.x)));
end   
if ~isequal(x.m,GF_TABLE_M) || ~isequal(x.prim_poly,GF_TABLE_PRIM_POLY)
    [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x);
end
% First invert wherever y1 is negative
ind=find(y<0);
x.x(ind) = gf_mex(x.x(ind),x.x(ind),x.m,'rdivide',x.prim_poly,GF_TABLE1,GF_TABLE2);
y1 = uint32(abs(y));  % Round and cast to required type
% Now raise each element to the given power:
z=gf(gf_mex(x.x,y1,x.m,'power',x.prim_poly,GF_TABLE1,GF_TABLE2),...
    x.m,x.prim_poly);  % <-- element-wise power

