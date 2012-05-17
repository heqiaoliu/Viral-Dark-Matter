function load(hObj, filename)
%LOAD Load a filter wizard file

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:18:24 $ 

if nargin < 2,
    filename = 'fwizdef.mat';
end

load(filename);

% If fwspec was not created by the load, the file is invalid.
if exist('fwspec') ~= 1,
    error(generatemsgid('InvalidParam'),'Invalid filter wizard data file.');
end

% Grab the coefficients for the selected architecture
coeffs = evaluatevars(fwspec.coef.(fwspec.arch));

isSOS = 0;
        
switch lower(fwspec.arch)
case {'df1', 'df2'},
    con = lower(fwspec.arch);

    % If the coefficients are in SOS, convert to transfer function for
    % constructor.  We will convert to sos later
    [r, c] = size(coeffs{1});
    if c == 6 & r ~= 1,
        isSOS = 1;
        [coeffs{1} coeffs{2}] = sos2tf(coeffs{:});
    end
case 'sfir',
    con = 'dffir';
case {'lar', 'lma', 'larma'}
    con = ['lattice', lower(fwspec.arch(2:end))];
end

Hd = feval(['dfilt.' con], coeffs{:});

if isSOS, Hd = sos(Hd); end

opts = fwspec.opt;

if opts.zeros, z = 'On';
else,          z = 'Off'; end

if opts.ones, o = 'On';
else,         o = 'Off'; end

if opts.neg_ones, n = 'On';
else,             n = 'Off'; end

if opts.delay_chains, d = 'On';
else,                 d = 'Off'; end

if strcmpi(fwspec.mdl.dest, 'existing'),
    fwspec.mdl.dest = 'current';
end

set(hObj, 'OptimizeZeros', z);
set(hObj, 'OptimizeOnes', o);
set(hObj, 'OptimizeNegOnes', n);
set(hObj, 'OptimizeDelayChains', d);
set(hObj, 'BlockName', fwspec.mdl.blockName);
set(hObj, 'Destination',fwspec.mdl.dest);

set(hObj, 'Filter', Hd);

% [EOF]
