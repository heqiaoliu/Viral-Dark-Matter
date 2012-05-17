function realizemdl(Hd,varargin)
%REALIZEMDL Filter realization (Simulink diagram).
%     REALIZEMDL(Hd) automatically generates architecture model of filter
%     Hd in a Simulink subsystem block using individual sum, gain, and
%     delay blocks, according to user-defined specifications.
%
%     REALIZEMDL(Hd, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) generates
%     the model with parameter/value pairs.
%
%     See also DFILT/REALIZEMDL

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.4.13 $  $Date: 2009/08/11 15:48:00 $

% Parse input
[hTar,doMapCoeffsToPorts] = local_parseinput(Hd,varargin{:});

% Create model
pos = createmodel(hTar); 

% Generate filter architecture
DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts);   % method defined in each DFILT class

% Expand dg_dfilt structure into directed graph
DG = expandToDG(DGDF,doMapCoeffsToPorts);

% Optimize direct graph
DG = optimizedg(Hd,hTar,DG);

% Generate mdl system
dg2mdl(DG,hTar,pos);

% Refresh connections
refreshconnections(hTar);

% Open system
opengeneratedmdl(hTar);

%------------------------------------------------------
function [hTar,doMapCoeffsToPorts] = local_parseinput(Hd,varargin)

% check if filter realizable
if ~isrealizable(Hd)
     error(generatemsgid('Notsupported'), ...
            'The structure %s is not supported.',Hd.FilterStructure);
end

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
