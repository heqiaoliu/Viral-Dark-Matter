function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN   Perform the actual design.

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:39:58 $

% Validate specifications
[N,F,E,A,nfpts] = validatespecs(hspecs);

% Determine if the filter is real
isreal = true;
if F(1)<0, isreal = false; end

% Weights
NBands = hspecs.NBands;
W = [this.B1Weights];
if isempty(W),
    W = ones(size(hspecs.B1Frequencies));
end
if NBands>1,
    WB2 = this.B2Weights;
    if isempty(WB2),
        WB2 = ones(size(hspecs.B2Frequencies));
    end
    W = [W WB2];
end

if NBands>2,
    WB3 = this.B3Weights;
    if isempty(WB3),
        WB3 = ones(size(hspecs.B3Frequencies));
    end
    W = [W WB3];
end
if NBands>3,
    WB4 = this.B4Weights;
    if isempty(WB4),
        WB4 = ones(size(hspecs.B4Frequencies));
    end
    W = [W WB4];
end
if NBands>4,
    WB5 = this.B5Weights;
    if isempty(WB5),
        WB5 = ones(size(hspecs.B5Frequencies));
    end
    W = [W WB5];
end
if NBands>5,
    WB6 = this.B6Weights;
    if isempty(WB6),
        WB6 = ones(size(hspecs.B6Frequencies));
    end
    W = [W WB6];
end
if NBands>6,
    WB7 = this.B7Weights;
    if isempty(WB7),
        WB7 = ones(size(hspecs.B7Frequencies));
    end
    W = [W WB7];
end
if NBands>7,
    WB8 = this.B8Weights;
    if isempty(WB8),
        WB8 = ones(size(hspecs.B8Frequencies));
    end
    W = [W WB8];
end
if NBands>8,
    WB9 = this.B9Weights;
    if isempty(WB9),
        WB9 = ones(size(hspecs.B9Frequencies));
    end
    W = [W WB9];
end
if NBands>9,
    WB10 = this.B10Weights;
    if isempty(WB10),
        WB10 = ones(size(hspecs.B10Frequencies));
    end
    W = [W WB10];
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
if isreal,
    method = thisrealmethod(this);
    if A(end)~=0 && rem(N,2),
        b = feval(method,N,E,{@multiband,F,A,W,false},{lgrid},'h');
    else
        b = feval(method,N,E,{@multiband,F,A,W,false},{lgrid});
    end
else
    method = thiscomplexmethod(this);
    b = feval(method,N,E,{@multiband,F,A,W,true},{lgrid});
end
    
varargout = {{b}};
    
%--------------------------------------------------------------------------
function [DH,DW] = multiband(N,FF,GF,W,F,A,myW,iscomplex,delay)
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
