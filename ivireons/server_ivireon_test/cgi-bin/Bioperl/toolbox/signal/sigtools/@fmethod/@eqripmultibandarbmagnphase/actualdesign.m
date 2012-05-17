function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN   Perform the actual design.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:29 $

% Validate specifications
[N,F,E,H,nfpts] = validatespecs(hspecs);

% Weights
W = [];
NBands = hspecs.NBands;
for i = 1:NBands,
    aux = get(this, ['B',num2str(i),'Weights']);
    if isempty(aux),
        aux = ones(size(get(hspecs,['B',num2str(i),'Frequencies'])));
    end
    W = [W aux];
end

if length(W)~=nfpts,
    error(generatemsgid('InvalidWeights'), ...
        'You must specify one weight per frequency point.')
end

% Density factor
lgrid = this.Densityfactor;
if lgrid<16,
    error(generatemsgid('InvaliddensityFactor'), 'The Density factor must be greater than 16.');
end

% Multi-band
b = cfirpm(N,E,{@multiband,F,H,W},{lgrid});
    
varargout = {{b}};
    
%--------------------------------------------------------------------------
function [DH,DW] = multiband(N,FF,GF,W,F,H,myW)

if nargin==2,
  % Return symmetry default:
  if strcmp(N,'defaults'),
    % Second arg (F) is cell-array of args passed later to function:
    num_args = length(FF);
    % Get the delay value:
    % Get their delay value:
    if num_args<5, F=[]; else F=FF{5}; end
    if num_args<6, H=[]; else H=FF{6}; end
    if num_args<7, myW=[]; else myW=FF{7}; end
    DH = 'real';
    return
  end
end

DH = interp1(F(:), H(:), GF);
DW = interp1(F(:), myW(:), GF);

% [EOF]
