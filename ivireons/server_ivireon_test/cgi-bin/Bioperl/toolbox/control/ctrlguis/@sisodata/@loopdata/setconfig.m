function setconfig(this,Design)
%SETCONFIG  Sets the loop configuration to one of the predefined choices.
%
%   L.SETCONFIG(Design)

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2006/11/17 13:24:27 $
Plant = this.Plant;
% New components should be initialized when data is already loaded
InitFlag = ~isempty(Plant); 
ConfigID = Design.Configuration;

% Delete listeners
if ishandle(this.Listeners.Tuned)
    delete(this.Listeners.Tuned)
end

% I/O names
this.Input = Design.Input;
this.Output = Design.Output;

% Create compensators
nC = length(Design.Tuned);
LocalCreateComps(this,nC,InitFlag);
for ct=1:nC
   Cid = Design.Tuned{ct};
   this.C(ct).Identifier = Cid;
end

if ConfigID>0
   % Built-in loop configurations
   if isequal(Plant,[]) || getconfig(this.Plant)<1
      % Switch plant representation
      Plant = sisodata.DistributedPlant;
      % Listener for change in open/closed loop connectivity
      this.Listeners.Fixed = handle.listener(Plant,Plant.findprop('LoopStatus'),...
            'PropertyPostSet',{@LocalResetClosedLoop this});
      this.Plant = Plant;
   end
   
   % Set plant configuration
   Plant.setconfig(ConfigID,Design.FeedbackSign);
   
else
   % Specifying augmented plant P directly
   if isequal(Plant,[]) || getconfig(this.Plant)>0
      % Switch plant representation
      Plant = sisodata.LumpedPlant;
      Plant.Configuration = ConfigID;
      % Listener for change in loop connectivity
      this.Listeners.Fixed = handle.listener(Plant,Plant.findprop('P'),...
         'PropertyPostSet',{@LocalChangeConfig this});
      this.Plant = Plant;
   end
   Plant.nLoop = nC;
   
end

% Build Open Loops
nL = length(Design.Loops);
delete(this.L);
this.L = [];

if isequal(nL,0)
    this.Listeners.Tuned = [];
else
    for ct=1:nL
        TLoops(ct) = sisodata.TunedLoop;
    end
    this.L = TLoops;

    % Listeners to compensator (@tunedmodel) properties
    L = handle.listener(this.L,findprop(this.L(1),'LoopStatus'),...
        'PropertyPostSet',@LocalChangeOpenLoopConfig);
    set(L,'CallbackTarget',this)
    this.Listeners.Tuned = L;
end
% RE: To complete update, caller should 
%     1) Issue ConfigChanged event (after data import)
%     2) Invoke LoopData.dataevent('all') to update derived data and plots.

%-------------------------Listeners-------------------------

function LocalChangeOpenLoopConfig(this,eventdata)
% Callback when changing the open/closed status of other loops 
% for a given loop
L = eventdata.AffectedObject;
idxC = find(L==this.L);
% Clear dependent data
this.reset('ol',idxC)
% Update dependency info and propagate to editors
this.send('ConfigChanged')  
% Send event to trigger update
% RE: Not enough to issue dataevent('gain',idxC) to update 
%     the editors for the loop #idxC. Indeed, changing the
%     status of outer loops may alter the number of plant and 
%     closed-loop poles seen by loop #idxC, resulting in errors
%     in the root locus editor
this.dataevent('all')


function LocalResetClosedLoop(eventsrc,eventdata,this)
% Clear augmented plant for closed-loop sim
this.reset('cl')


function LocalChangeConfig(eventsrc,eventdata,this)
% Responds to change in loop topology
% Rebuild dependency lists for each open loop 
% REVISIT For config=0 (SCD case)plant cannot change during session
% this.Plant.oloopdepend(this.L)
% Notify peers (so that editors can rebuild their dependency lists)
% this.send('ConfigChanged')  
% % Send event to trigger global update
% this.dataevent('all')


%---------------- Local Functions -------------------------

function LocalCreateComps(this,nC,InitFlag)
% Adjust the lists of fixed and tuned models
nC0 = length(this.C);
if nC0>nC,
   delete(this.C(nC+1:nC0));
   this.C = this.C(1:nC);
else
   for ct=nC0+1:nC
      % Compensator model
      C = sisodata.TunedZPK;
      C.SSData = ltipack.ssdata;
      this.C = [this.C ; C];
   end
end
