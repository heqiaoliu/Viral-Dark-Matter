function BlockFactors = utComputeBlockFactors(~,LinTs,BlockSubs)
% UTCOMPUTEBLOCKFACTORS  Compute block substitution factors.  This is used
% to fold fixed delay free lti terms into the Jacobian data structure to
% ensure the proper sampling in multi-rate linearization situations.
%
 
% Author(s): John W. Glass 11-Sep-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/11/09 16:35:16 $

BlockFactors = struct('Name',cell(numel(BlockSubs),1),'InputFixed',[],...
                            'OutputFixed',[],'Factor',[],'FoldBlock',[]);
for ct = numel(BlockSubs):-1:1
    sys = BlockSubs(ct).Value;
    if isfield(BlockSubs(ct),'FoldBlock')
        FoldBlock = BlockSubs(ct).FoldBlock;
    else
        FoldBlock = false;
    end
    BlockFactors(ct,1) = LocalFactorSystem(sys,BlockSubs(ct).Name,LinTs,FoldBlock); 
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BlockFactors = LocalFactorSystem(sys,Name,LinTs,FoldBlock)

Factor = [];
[ny,nu] = size(sys);

if (isa(sys,'tf') || isa(sys,'zpk')) && FoldBlock 
    sys = ss(sys);
    if isempty(get(sys,'E'))
        InputFixed = ss(sys);
        [ny,~] = size(sys);
        OutputFixed = ss(eye(ny,ny));
    else
        Factor = sys;
        InputFixed = ss(eye(nu,nu));
        OutputFixed = ss(eye(ny,ny));
    end
elseif isa(sys,'double') && FoldBlock
    InputFixed = sys;
    [ny,~] = size(sys);
    OutputFixed = speye(ny,ny);
elseif isa(sys,'ss') && FoldBlock
    sysTs = sys.Ts;
    InputDelay = sys.InputDelay;
    OutputDelay = sys.OutputDelay;
    InternalDelay = sys.InternalDelay;
    if any(InternalDelay ~= 0) || ...
            (any(InputDelay ~= 0) && any(OutputDelay ~= 0)) || ...
            ~isempty(get(sys,'E'))
        Factor = sys;
        InputFixed = ss(eye(nu,nu));
        OutputFixed = ss(eye(ny,ny));
    elseif any(InputDelay ~= 0)
        % --------------    ---------  ---------  --------
        % | e^-st*G(s) | -> | e^-ft |->| e^-Ht |->| G(s) |
        % --------------    ---------  ---------  --------
        % - f is the fractional delay if system is continuous and
        % linearization Ts is > 0; otherwise f is zero.  This is returned
        % in InputFixed
        % - H is the whole delay with fraction f removed if Ts > 0.  This
        % is returned in Factor
        % - G(s) is returned in OutputFixed.
        if sysTs == 0 && LinTs > 0
            [FractDelay,WholeDelay] = LocalComputeFractionalDelay(InputDelay,LinTs);
            InputFixed = ss(eye(nu,nu),'Ts',sysTs,'OutputDelay',FractDelay);
            Factor = sys;Factor.InputDelay = WholeDelay;
            OutputFixed = ss(eye(ny,ny));
        else
            Factor = sys;
            InputFixed = ss(eye(nu,nu));
            OutputFixed = ss(eye(ny,ny));
        end        
    elseif any(sys.OutputDelay ~= 0)
        % --------------    --------  ---------  ---------
        % | G(s)*e^-st | -> | G(s) |->| e^-Ht |->| e^-ft |
        % --------------    --------  ---------  ---------
        % - f is the fractional delay if system is continuous and
        % linearization Ts is > 0; otherwise f is zero.  This is returned
        % in InputFixed
        % - H is the whole delay with fraction f removed if Ts > 0.  This
        % is returned in Factor
        % - G(s) is returned in OutputFixed.
        if sysTs == 0 && LinTs > 0
            [FractDelay,WholeDelay] = LocalComputeFractionalDelay(OutputDelay,LinTs);
            OutputFixed = ss(eye(ny,ny),'Ts',sysTs,'OutputDelay',FractDelay);
            Factor = sys;Factor.OutputDelay = WholeDelay;
            InputFixed = ss(eye(nu,nu));
        else
            Factor = sys;
            InputFixed = ss(eye(nu,nu));
            OutputFixed = ss(eye(ny,ny));
        end
    else
        InputFixed = sys;
        OutputFixed = ss(eye(ny,ny));
    end    
else
    Factor = sys;
    InputFixed = ss(eye(nu,nu));
    OutputFixed = ss(eye(ny,ny));
end

BlockFactors = struct('Name',Name,'InputFixed',InputFixed,...
                            'OutputFixed',OutputFixed,'Factor',Factor,...
                            'FoldBlock',FoldBlock);
                        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FractDelay,WholeDelay] = LocalComputeFractionalDelay(DelayValue,Ts)

NSamples = floor(DelayValue/Ts);
WholeDelay = NSamples*Ts;
FractDelay = DelayValue - WholeDelay;