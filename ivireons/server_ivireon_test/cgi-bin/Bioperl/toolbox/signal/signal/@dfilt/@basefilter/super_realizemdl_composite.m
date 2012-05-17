function super_realizemdl_composite(Hd,varargin)
%SUPER_REALIZEMDL_COMPOSITE realize composite model

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:48:08 $

% Parse input
[hTar,doMapCoeffsToPorts] = local_parseinput(Hd,varargin{:});

% Create model
pos = createmodel(hTar);

% Generate filter architecture
msg = dgdfgen(Hd,hTar,doMapCoeffsToPorts,pos);   % method defined in each DFILT class

if ~isempty(msg),
    delete_block(hTar.system);
    error(generatemsgid('NotSupported'),msg);
else
    % Refresh connections
    refreshconnections(hTar);
    
    % Optimisations
    optimize_mdl(hTar, Hd);
    
    % Open system
    opengeneratedmdl(hTar);
    
end

% -------------------------------------------------------------
function optimize_mdl(hTar, Hd)

% Optimize zero gains
if strcmpi(hTar.OptimizeZeros, 'on'),
     optimizezerogains(hTar, Hd);
end

% Optimize unity gains
if strcmpi(hTar.OptimizeOnes, 'on'),
     optimizeonegains(hTar, Hd);
end

% Optimize -1 gains
if strcmpi(hTar.OptimizeNegOnes, 'on'),
     optimizenegonegains(hTar, Hd);
end

% Optimise delay chains
if strcmpi(hTar.OptimizeDelayChains, 'on'),
    optimizedelaychains(hTar);
end
%------------------------------------------------------
function [hTar,doMapCoeffsToPorts] = local_parseinput(Hd,varargin)

% Parse inputs to target
hTar = uddpvparse('dspfwiztargets.realizemdltarget', varargin{:});

% Clear gains and delays
hTar.gains = [];
hTar.delays = [];

% Check if the required license is installed
checkrequiredlicense(Hd,hTar)

% Check MapCoeffsToPorts state and coefficient names
if ~strcmpi(hTar.MapCoeffsToPorts,'on')&&~isempty(hTar.CoeffNames),
    error(generatemsgid('InvalidParameter'), ...
        'The MapCoeffsToPorts property must be ''on'' for the CoeffNames property to apply.');
end

% Parse parameters to hTar
try
    % Get coefficient names and values
    [hTar,doMapCoeffsToPorts] = parse_coeffstoexport(Hd,hTar);
    
    % Set filter states to hTar
    hTar = parse_filterstates(Hd,hTar);
catch ME
    throwAsCaller(ME);
end


% [EOF]
