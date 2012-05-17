function addpz(Editor,varargin)
%ADDPZ  Adds pole or zero to the Nichols Editor.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2006/06/20 20:02:45 $
LoopData = Editor.LoopData;

% Gather info about added root
AddInfo =  Editor.EditModeData; 

% Determine which Compensator to add PZGroup to
C = addPZDialog(Editor, AddInfo.Group, AddInfo.Root);

if isempty(C)
    % No valid compensators to add pzgroup to
    return
end

Ts = C.Ts;

% Handles
PlotAxes = getaxes(Editor.Axes);
EventMgr = Editor.EventManager;

% Get Nichols plot data in current units
[Gain, Magnitude, Phase, Frequency] = nicholsdata(Editor);

% Acquire new pole/zero position in current units
CP = get(PlotAxes, 'CurrentPoint');
X = max(min(Phase), min(CP(1,1), max(Phase)));
Y = max(min(Magnitude), min(CP(1,2), max(Magnitude)));

% Find the frequency of the closest (visually) point on the Nichols curve.
FreqPZ = Editor.project(X, Y, Phase, Magnitude, Frequency);

% Convert Pole/Zero frequency to rad/sec
W = unitconv(FreqPZ, Editor.FrequencyUnits, 'rad/sec');

% Determine root value based on pole/zero type
[Zeros, Poles, GroupType, Status, Action] = ...
    LocalGetRootValue(W, AddInfo.Group, AddInfo.Root, Ts, C.Identifier);

% Start transaction
T = ctrluis.transaction(Editor.LoopData,'Name',Action,...
    'OperationStore','on','InverseOperationStore','on');

% Add new pole/zero group to database
C.addPZ(GroupType, Zeros, Poles);

% Register transaction 
EventMgr.record(T);

% Notify peers of data change
Editor.LoopData.dataevent('all');

% Confirm operation in status bar and update history
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalGetRootValue
% Infers specified root value from mouse location
% RE: * Uses only the natural frequency info (W = Wn)
%     * W is in rad/sec
% ----------------------------------------------------------------------------%
function [Zeros, Poles, GroupType, Status, Action] = ...
    LocalGetRootValue(W, GroupType, PZType, Ts, CompID)
% System type
if Ts
  DomainVar = 'z';
else
  DomainVar = 's';
end
CompID = sprintf('%s(%s)', CompID, DomainVar);

switch GroupType
 case 'Real'
  % Real pole/zero. RE: Assume stability
  R = LocalRootValue(-W, Ts);
  if strcmpi(PZType, 'Zero')
    Zeros = R;  Poles = zeros(0,1);
  else
    Poles = R;  Zeros = zeros(0,1);
  end
  Status = sprintf('Added real %s to %s at %s = %.3g', ...
		   lower(PZType), CompID, DomainVar, R);
  Action = sprintf('Add %s', PZType);
  
 case 'Complex'
  % Complex pole zero: assume stability + damping = 1.0
  R = LocalRootValue(-W,Ts);
  if strcmpi(PZType,'Zero')
    Zeros = [R; R];  Poles = zeros(0,1);
  else
    Poles = [R; R];  Zeros = zeros(0,1);
  end
  Status = sprintf('Added complex pair of %ss to %s at %s = %.3g %s %.3gi', ...
		   lower(PZType), CompID, DomainVar, real(R), '+/-', 0);
  Action = sprintf('Add %s', PZType);
  
 case 'Lead'
  % Lead network (s+tau1)/(s+tau2)  where tau1<tau2
  Zeros = LocalRootValue(-W/1.5, Ts);
  Poles = LocalRootValue(-W, Ts);
  GroupType = 'LeadLag';
  Status = sprintf('Added lead network to %s with zero at %s = %.3g and pole at %s = %.3g', ...
		   CompID, DomainVar, Zeros, DomainVar, Poles);
  Action = 'Add Lead';
  
 case 'Lag'
  % Lag network (s+tau1)/(s+tau2)  where tau1>tau2
  Zeros = LocalRootValue(-1.5*W, Ts);
  Poles = LocalRootValue(-W, Ts);
  GroupType = 'LeadLag';
  Status = sprintf('Added lag network to %s with zero at %s = %.3g and pole at %s = %.3g', ...
		   CompID, DomainVar, Zeros, DomainVar, Poles);
  Action = 'Add Lag';
  
 case 'Notch'
  % Notch filter:
  % default is zeta1 = 0.05, zeta2 = 0.5 (1/2 max width and 20dB depth)
  z1 = 0.05;   z2 = 0.5;
  r1 = W * (-z1 + 1i*sqrt(1-z1^2));
  r2 = W * (-z2 + 1i*sqrt(1-z2^2));
  Zeros = LocalRootValue([r1; conj(r1)], Ts);
  Poles = LocalRootValue([r2; conj(r2)], Ts);
  Status = sprintf('Added notch filter to %s with zeros at %s = %.3g %s %.3gi and poles at %s = %.3g %s %.3gi', CompID, ...
	  DomainVar, real(Zeros(1)), '+/-', abs(imag(Zeros(1))), ...
	  DomainVar, real(Poles(1)), '+/-', abs(imag(Poles(1))));
  Action = 'Add Notch';
end


% ----------------------------------------------------------------------------%
% Function: LocalRootValue
% Convert to discrete time values if necessary
% ----------------------------------------------------------------------------%
function R = LocalRootValue(R, Ts)
if Ts,
  R = exp(Ts*R);
end




    
    



