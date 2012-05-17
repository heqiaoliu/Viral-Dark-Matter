function sent = SendEventsToAllSameBD(this, simcmd)
% SendEventsToAllSameBD Send a given event to all scopes on the same 
% Block diagram. For Rapid AcceleratorMode, when Simulink itself does 
% not send events
  
switch simcmd
    case 'pause'
        ev.Type = 'PauseEvent';
    case 'continue'
        ev.Type = 'ContinueEvent';
    otherwise
        % Simulink itself throws event for the rest
        ev.Type = [];
end

% fake the event throw
if ~isempty(ev.Type)
    sent = true;
    TrapEvents(this.State,ev);
    others = findScopesSameBD(this);
    for i=1:numel(others)
        TrapEvents(others(i).DataSource.State,ev);
    end
else
    sent = false;
end

end %EOF

