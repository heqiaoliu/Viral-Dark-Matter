function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN   Perform the actual design.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:34 $

% Validate specifications
[N,F,A,P,nfpts] = validatespecs(hspecs);

% Weights
W = this.Weights;
if isempty(W),
    W = ones(size(F));
elseif length(W)~=nfpts,
    error(generatemsgid('InvalidWeights'), ...
        'The vectors ''Weights'' and ''Frequencies'' must have the same length.')
end

% Density factor
lgrid = this.Densityfactor;
if lgrid<16,
    error(generatemsgid('InvaliddensityFactor'), 'The Density factor must be greater than 16.');
end

% Single band
if F(1)<0
    FF = [-1 1];
else
    FF = [0 1];
end
b = cfirpm(N,FF,{@singleband,F,A,P,W},{lgrid}); 
   
varargout = {{b}};
    
%--------------------------------------------------------------------------
function [DH,DW] = singleband(N,FF,GF,W,F,A,P,myW)
% Frequency response called by CFIRPM (twice)

if nargin==2,
  % Return symmetry default:
  if strcmp(N,'defaults'),
    % Second arg (F) is cell-array of args passed later to function:
    num_args = length(FF);
    if num_args<5, F=[]; else F=FF{5}; end
    if num_args<6, A=[]; else A=FF{6}; end
    if num_args<7, P=[]; else P=FF{7}; end
    if num_args<8, myW=[]; else myW=FF{8}; end
    return
  end
end

% Build the complex response
H = A.*exp(j*P);

DH = interp1(F(:), H(:), GF);
DW = interp1(F(:), myW(:), GF);

% [EOF]
