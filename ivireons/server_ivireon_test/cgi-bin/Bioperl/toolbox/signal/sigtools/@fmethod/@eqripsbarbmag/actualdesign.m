function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN   Perform the actual design.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:44:23 $

% Validate specifications
[N,F,A,P,nfpts] = validatespecs(hspecs);

% Determine if the filter is real
isreal = true;
if F(1)<0, isreal = false; end

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
if isreal,
    FF = [0 1];
    method = thisrealmethod(this);
    if A(end)~=0 && rem(N,2),
        b = feval(method,N,FF,{@singleband,F,A,W,false},{lgrid},'h');
    else
        b = feval(method,N,FF,{@singleband,F,A,W,false},{lgrid});
    end
else
    FF = [-1 1];
    method = thiscomplexmethod(this);
    b = feval(method,N,FF,{@singleband,F,A,W,true},{lgrid}); 
end
    
varargout = {{b}};
    
%--------------------------------------------------------------------------
function [DH,DW] = singleband(N,FF,GF,W,F,A,myW,iscomplex,delay)
% Frequency response called by FIRPM and CFIRPM (twice)

if nargin==2,
  % Return symmetry default:
  if strcmp(N,'defaults'),
    % Second arg (F) is cell-array of args passed later to function:
    num_args = length(FF);
    % Get the delay value:
    % Get their delay value:
    if num_args<5, F=[]; else F=FF{5}; end
    if num_args<6, A=[]; else A=FF{6}; end
    if num_args<7, myW=[]; else myW=FF{7}; end
    if num_args<8, iscomplex=true; else iscomplex=FF{8}; end
    if num_args<9, delay=0; else delay=FF{9}; end
    % Use delay arg to base symmetry decision:
    if isequal(delay,0), DH='even'; else DH='real'; end
    return
  end
end

% Standard call:
if nargin<9, delay = 0; end
delay = delay + N/2;  % adjust for linear phase

DH = interp1(F(:), A(:), GF);
if iscomplex,
    DH = DH .* exp(-1i*pi*GF*delay);
end
DW = interp1(F(:), myW(:), GF);

% [EOF]
