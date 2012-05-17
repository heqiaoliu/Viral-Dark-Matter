function C = utTuningPID(Model,Type,Rule)
%UTTUNINGPID  PID design for a SISO LTI model using classical rules. 
%
%   C = UTTUNINGPID(MODEL,TYPE,RULE) designs a PID controller for a SISO LTI plant. 
%
%   Input:
%       MODEL:  LTI except @frd, SISO, proper, stable or integrating
%
%       TYPE:   'p', 'pi', 'pid', 'pidf'
%
%       RULE:   'amigocl','amigool','chr','simc','zncl','znol'
%
%   Output:
%       C:      @pidstd object (discretized if Model is in discrete time)
%
%   Assumptions: PID loop has unit negative feedback

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.11 $  $Date: 2010/04/11 20:29:31 $

%% Preprocessing Model
% check siso 
if ~issiso(Model)
    ctrlMsgUtils.error('Control:design:PIDTuning5')
end
% check frd
if ~isa(Model,'lti') || isa(Model,'frd')
    ctrlMsgUtils.error('Control:design:PIDTuning6')
end
% check proper
[isProper, Model] = isproper(Model);
if ~isProper
    ctrlMsgUtils.error('Control:design:PIDTuning7')
end
% check Ts
SysData = getPrivateData(Model);
Ts = SysData.Ts;
if Ts<0
    ctrlMsgUtils.error('Control:design:PIDTuning3');
end
% check stability: stable or integrating
Poles = pole(SysData);
if Ts==0
    boo = all(real(Poles)<=0);
else
    boo = all(abs(Poles)<=1);
end
if ~boo
    ctrlMsgUtils.error('Control:design:PIDTuning4');
end

%% Preprocessing Type
AvailableTypes = {'p','pi','pid','pidf'};
if ischar(Type) && ismember(lower(Type),AvailableTypes)
    Type = lower(Type);    
else
    ctrlMsgUtils.error('Control:design:PIDTuning2')
end

%% Preprocessing Rule
AvailableRules = {'amigool','amigocl','chr','simc','zncl','znol'};
if ischar(Rule) && ismember(lower(Rule),AvailableRules)
    Rule = lower(Rule);    
else
    ctrlMsgUtils.error('Control:design:PIDTuning1')
end

%% dispatch calls to pid tuning sub-routines
switch lower(Rule)
    case {'amigool','chr','simc','znol'}
        C = utTuningStepResponse(Model,Type,Rule);
    case {'zncl','amigocl'}
        C = utTuningFrequencyResponse(Model,Type,Rule);            
end

