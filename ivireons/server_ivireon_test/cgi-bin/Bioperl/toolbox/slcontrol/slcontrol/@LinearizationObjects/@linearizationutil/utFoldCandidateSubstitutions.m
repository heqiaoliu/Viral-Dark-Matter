function [Jfold,BlockSubs] = utFoldCandidateSubstitutions(this,Jlft,BlockSubs,LinTs)
% UTFOLDCANDIDATESUBSTITUTIONS  Fold in delay free lti block substitutions.
%
 
% Author(s): John W. Glass 11-Sep-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:35:03 $

% Extract the block I/O info
OutputInfo = Jlft.Mi.OutputInfo;
BlockOutputs = OutputInfo(:,1);
BlockOutputChannels = OutputInfo(:,2);

% Keep track of the output delays
OutputDelays = zeros(size(J.D,1),1);

for ct = numel(BlockSubs):-1:1
    sys = BlockSubs(ct).Replacement;
    [InputFixed,OutputFixed,Factor] = LocalFactorSystem(sys,LinTs);
    BlockSubs(ct).Replacement = Factor;
    if isempty(Factor) && isempty(OutputFixed)
        Jlft = LocalIntegrateFixedTerm(Jlft,InputFixed);
    end        
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [InputFixed,OutputFixed,Factor] = LocalFactorSystem(sys,LinTs)

InputFixed = [];
OutputFixed = [];
Factor = [];
[ny,nu] = size(sys);
sysTs = sys.Ts;

if isa(sys,'tf') || isa(sys,'zpk') || isa(sys,'double')
    InputFixed = sys;
elseif isa(sys,'ss')
    if ~isempty(sys.InternalDelay) || ...
            (~isempty(sys.InputDelay) && ~isempty(sys.OutputDelay))
        Factor = sys;
    elseif ~isempty(sys.InputDelay)
        % --------------    --------  --------  --------
        % | e^-st*G(s) | -> | e-ft |->| e-Ht |->| G(s) |
        % --------------    --------  --------  --------
        % - f is the fractional delay if system is continuous and
        % linearization Ts is > 0; otherwise f is zero.  This is returned
        % in InputFixed
        % - H is the whole delay with fraction f removed if Ts > 0.  This
        % is returned in Factor
        % - G(s) is returned in OutputFixed.
        if sys.Ts == 0 && Ts > 0
            [FractDelay,WholeDelay] = LocalComputeFractionalDelay(sys.InputDelay,LinTs);
            InputFixed = ss(eye(nu,nu),'Ts',sysTs,'OutputDelay',FractDelay);
            Factor = ss(eye(nu,nu),'Ts',sysTs,'InputDelay',WholeDelay);
            OutputFixed = sys;
            OutputFixed.InputDelay = zeros(size(OutputFixed.InputDelay));
        else
            Factor = sys;
        end        
    elseif ~isempty(sys.OutputDelay)
        % --------------    --------  --------  --------
        % | G(s)*e^-st | -> | G(s) |->| e-Ht |->| e-ft |
        % --------------    --------  --------  --------
        % - f is the fractional delay if system is continuous and
        % linearization Ts is > 0; otherwise f is zero.  This is returned
        % in InputFixed
        % - H is the whole delay with fraction f removed if Ts > 0.  This
        % is returned in Factor
        % - G(s) is returned in OutputFixed.
        if sys.Ts == 0 && Ts > 0
            [FractDelay,WholeDelay] = LocalComputeFractionalDelay(sys.OutputDelay,LinTs);
            OutputFixed = ss(eye(nu,nu),'Ts',sysTs,'OutputDelay',FractDelay);
            Factor = ss(eye(nu,nu),'Ts',sysTs,'OutputDelay',WholeDelay);
            InputFixed = sys;
            InputFixed.InputDelay = zeros(size(InputFixed.InputDelay));
        else
            Factor = sys;
        end
    else
        InputFixed = sys;
    end    
else
    Factor = sys;
end