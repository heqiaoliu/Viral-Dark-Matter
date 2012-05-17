function [sys, iostruct] = utOrderNameStates(this,model,sys,J,userdef_stateName,iostruct,LinData)
% UTORDERNAMESTATES  Order the states of a linearization.
%
 
% Author(s): John W. Glass 19-Aug-2008
%   Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/12/07 20:48:59 $

StateOrder = LinData.StateOrder;
opt = LinData.opt;

[~,~,nk] = size(sys);
for ct = 1:nk
    StateNames = regexprep(sys(:,:,ct).StateName,'\n',' ');
    
    if ~isempty(StateOrder) && ~isa(sys,'uss')
        % Remove carriage returns in the specified state order
        StateOrder = regexprep(StateOrder,'\n',' ');
        % Check to make sure that all the block names are valid
        all_stateBlockPath = regexprep(J(ct).stateBlockPath,'\n',' ');
        for ct2 = 1:numel(StateOrder)
            if ~any(strcmp(StateOrder{ct2},J(ct).stateName)) && ...
                    ~any(strcmp(StateOrder{ct2},all_stateBlockPath))
                % Check to see if state is in an accelerated mode model
                % reference.
                if strcmp(StateOrder{ct2},getBlockPath(slcontrol.Utilities,StateOrder{ct2}))
                    ctrlMsgUtils.error('Slcontrol:linearize:InvalidBlockNameforStateOrder',model,StateOrder{ct2})
                else
                    ctrlMsgUtils.error('Slcontrol:linearize:InvalidAccelBlockNameforStateOrder',model)
                end
            end
        end
        
        ind = [];
        indfull = (1:length(sys(:,:,ct).a))';
        
        % Loop over the state objects
        for ct2 = 1:length(StateOrder)
            stateind = find(strcmp(StateOrder(ct2),StateNames));
            if isempty(stateind)
                stateind = find(strcmp(StateOrder(ct2),userdef_stateName));
            end
            % Check to see if the state index has been used
            indselect = find(indfull(stateind));
            indfull(stateind(indselect)) = zeros(size(stateind(indselect)));
            ind = [ind;stateind(indselect)];
        end
        % Add additional states due to transport delays, etc
        ind = [ind;find(indfull)];
        StateNames = StateNames(ind);
        userdef_stateName = userdef_stateName(ind);
        sys(:,:,ct) = xperm(sys(:,:,ct),ind);
    end
    
    % Store the full block path
    iostruct(ct).FullStateName = StateNames;
    % Find the states that are not set to ? because of rate conversions
    ind = setxor(find(strcmp(StateNames,'?')),1:length(StateNames));
    
    % Truncate the state names
    if strcmp(opt.UseFullBlockNameLabels,'off')
        % Check for user defined state names
        for ct2 = numel(ind):-1:1
            if ~isempty(userdef_stateName{ind(ct2)})
                StateNames{ind(ct2)} = userdef_stateName{ind(ct2)};
                ind(ct2) = [];
            end
        end
        StateNames(ind) = uniqname(slcontrol.Utilities,StateNames(ind),true);
    else
        StateNames(ind) = uniqname(slcontrol.Utilities,StateNames(ind),false);
    end
    if nk == 1
        sys.StateName = StateNames;
    else
        sys(:,:,ct).StateName = StateNames;
    end
end
end
