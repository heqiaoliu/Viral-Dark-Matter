function y = random(obj,varargin)
%RANDOM Random number generation. 
%   Y = RANDOM(PD) generates a random number drawn from the
%   probability distribution PD.
%
%   Y = RANDOM(PD,N) generates an N-by-N array Y of random numbers.
%
%   Y = RANDOM(PD,N,M,...) or Y=RANDOM(PD,[N,M,...]) generates an
%   N-by-M-by-... array of random numbers.
%
%   RANDOM displays an error message If PD is created from a censored
%   sample and has total probability less than 1.
%
%   See also ProbDist, ProbDistUnivParam, RANDOM.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1.2.1 $  $Date: 2010/06/14 14:30:39 $

ksinfo = obj.ksinfo;
if ksinfo.maxp<1
    error('stats:ProbDistUnivKernel',...
          'No random sample is possible because the total probability (%f) is less than 1.',...
          ksinfo.maxp)
end

% Randomly select a point where the ecdf jumps
u = rand(varargin{:});
sz = size(u);
edges = min([0; cumsum(ksinfo.weight(:))],1); % guard histc against accumulated round-off;
edges(end) = 1; % get the upper edge exact
[~,bin] = histc(u(:),edges);
y = ksinfo.ty(bin);
y = reshape(y,sz);

% Add random noise
y = y + obj.BandWidth*noise(obj.Kernel,size(y));

% Transform if necessary
L = ksinfo.L;
U = ksinfo.U;
if L==0 && U==Inf
    y = exp(y);
elseif isfinite(ksinfo.U)
    ey = exp(y);
    y = (U*ey + L) ./ (1 + ey);
end

% ----------------
function z = noise(kernel,sz)
% Computes inverse kernel cdfs for kernels defined in the function
% stats/private/statkskernelinfo

switch(kernel)
    case 'normal'
        z = randn(sz);
    case 'box'
        z = -sqrt(3) + 2*sqrt(3)*rand(sz);
    case 'triangle'
        u = -1 + 2*rand(sz);
        z = sqrt(6) * sign(u) .* (1-sqrt(abs(u)));
    case 'epanechnikov'
        % Need to compute the icdf by solving the quadratic equation
        %   x^2 + (2-4p)x + 1 = 0
        b = 2 - 4*rand(sz);

        % Get one root
        r = (-b + sqrt(b.^2 - 4)) / 2;

        % The desired result is z=(s-t) where s and t are defined as
        % below.  Get t using the right cube root of r.  Compute s from t.
        % Remove any imaginary part of z caused by roundoff error, and
        % scale by the standard kernel width sqrt(5).
        t = exp(2*1i*2*pi/3) * r.^(1/3);
        s = -1./t;
        z = sqrt(5) * real(s - t);
end
