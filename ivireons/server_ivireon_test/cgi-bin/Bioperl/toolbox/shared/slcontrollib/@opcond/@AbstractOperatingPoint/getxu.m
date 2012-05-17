function [x,u,varargout] = getxu(this)
%

% GETXU Extract states and inputs from operating points
%
%   X = GETXU(OP_POINT) extracts a vector of state values, X, from the
%   operating point object, OP_POINT. The ordering of states in X is the
%   same as that used by Simulink.
%
%   [X,U] = GETXU(OP_POINT) extracts a vector of state values, X, and a
%   vector of input values, U, from the operating point object, OP.
%   The ordering of states in X, and inputs in U, is the same as that used
%   by Simulink.
%
%   [X,U,XSTRUCT] = GETXU(OP_POINT) extracts a vector of state values, X,
%   a vector of input values, U, and a structure of state values, XSTRUCT,
%   from the operating point object, OP_POINT. The structure of state
%   values, xstruct, has the same format as that returned from a Simulink
%   simulation. The ordering of states in X and XSTRUCT, and inputs in U,
%   is the same as that used by Simulink.
%
%   See also OPERPOINT, OPERSPEC.

%  Author(s): John Glass
%  Revised:
%   Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2010/04/30 00:40:07 $

% The model must be in normal mode to query
% Create the model parameter manager
want = struct('SimulationMode', 'normal');
ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(this.Model);
ModelParameterMgr.ModelParameters = want;
ModelParameterMgr.loadModels;
ModelParameterMgr.prepareModels;

% Get the states of the system
[sizes, x0, x_str, ts, tsx] = feval(this.Model,[],[],[],'compile');

% Get the block type for error handling
mdlref = find_system(this.Model,'BlockType','ModelReference');
if ~isempty(mdlref) && ~isempty(intersect(mdlref,x_str))    
    % Terminate compilation
    feval(this.Model,[],[],[],'term');
    
    % Return the model to its previous context
    ModelParameterMgr.restoreModels;
    ModelParameterMgr.closeModels;
    ctrlMsgUtils.error('SLControllib:opcond:StateVectorNotSupportedGETXU',this.Model);
end

try
    % Remove the offsets
    tsx = tsx(:,1);

    % Initialize the vectors
    x = zeros(size(x_str));

    % Find the unique state names
    stateblock = get(this.States,{'Block'});
    statename = get(this.States,{'StateName'});

    % Loop over each of the state in the state vector
    x_str_unique = unique(x_str);

    for ct = 1:numel(x_str_unique)
        curr_state = x_str_unique{ct};
        offset = find(strcmp(curr_state,x_str),1);
        ind = find(strcmp(curr_state,x_str));
        tsx_block = tsx(ind);
        % Determine if there are state names
        if any(tsx_block == 0)
            if isfield(get_param(curr_state,'ObjectParameters'),'ContinuousStateAttributes')
                stateattrib = get_param(curr_state,'CompiledContinuousStateAttributes');
            else
                stateattrib = [];
            end
        else
            stateattrib = [];
        end
        
        % If there are no state attributes and a single sample time write into
        % the state vector using a state object.
        if isempty(stateattrib) && numel(unique(tsx_block)) == 1
            ind_state_obj = strcmp(curr_state,stateblock);
            x(ind) = this.States(ind_state_obj).x;
        else
            % Handle the continuous time states first
            ind_cont = ind(tsx_block==0);
            if ~isempty(ind_cont)
                if isempty(stateattrib)
                    ind_state_obj = strcmp(curr_state,stateblock);
                    Ts_state_obj = get(this.States(ind_state_obj),'Ts');
                    % This means that there is a single continuous state
                    ind_state_obj_cont = ind_state_obj(Ts_state_obj(:,2)==0);
                    x(ind_cont) = this.States(ind_state_obj_cont).x;
                    offset = offset + numel(ind_cont);
                else
                    for ct2 = 1:numel(stateattrib)
                        ind_state_obj = strcmp(stateattrib(ct2).name,statename);
                        x(offset:offset+stateattrib(ct2).width-1) = this.States(ind_state_obj).x;
                        offset = offset + stateattrib(ct2).width;
                    end
                end
                % Remove the continuous sample times
                tsx_block(tsx_block==0) = [];
            end

            % Handle the remaining discrete states
            ind_state_obj = strcmp(curr_state,stateblock);
            Ts_state_obj = get(this.States(ind_state_obj),'Ts');
            
            tsx_block_unique = unique(tsx_block);
            for ct2 = 1:numel(tsx_block_unique)
                ind_state_obj_disc = ind_state_obj(Ts_state_obj(:,2)==tsx_block_unique(ct2));
                x(offset:offset+nstates-1) = this.States(ind_state_obj_disc).x;
                offset = offset + this.States(ind_state_obj_disc).Nx;
            end
        end
    end
catch Ex
    % Terminate compilation
    feval(this.Model,[],[],[],'term');
    % Return the model to its previous context
    pop_context(linutil, this.Model, have);
    throwAsCaller(Ex)
end

% Terminate compilation
feval(this.Model,[],[],[],'term');

% Return the model to its previous context
ModelParameterMgr.restoreModels;
ModelParameterMgr.closeModels;

% Create the Simulink structure format if requested
if (nargout == 3)
    varargout{1} = getstatestruct(this);
end
    
% Extract the input levels handle multivariable case
u = get(this.Inputs,{'u'});
u = vertcat(u{:});
