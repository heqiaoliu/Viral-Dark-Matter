function [A,B,C,D] = sortJacobian(this)
% SORTJACOBIAN  Sort the Jacobian for the trim optimization.
%
 
% Author(s): John W. Glass 03-Mar-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/03/26 17:53:44 $

% Compute the Jacobian
J = feval(this.model,[],[],[],'jacobian');
% Get the A,B,C,D matrices
a = J.A; b = J.B; c = J.C; d = J.D; 

% Cache so that this calculation is completed only once
if isempty(this.JacobianSortVector)
    if ~isempty(this.statestructure.signals)
        % Removes states from a linearization that are not being trimmed.  These
        % include:
        %   - Delay blocks will have their Pade order turned to 1 outside of this
        %   function.
        %   - States of non-double block like a discrete integrator and unit delay
        %   - States of a rate transition block are not registered as discrete
        %   states.

        % Get the state names and their corresponding block types
        stateBlockPath = J.blockName;
        for ct = numel(stateBlockPath):-1:1
            BlockTypes{ct} = get_param(getBlockPath(slcontrol.Utilities,stateBlockPath{ct}),'BlockType');
        end

        % Find the rate transition blocks
        ind_rate_transition = find(strcmp('RateTransition',BlockTypes));

        % Find the unit delay blocks that are non-double data typed
        ind_unit_delay = find(strcmp('UnitDelay',BlockTypes));
        ind_unit_delay_nondouble = [];
        for ct = 1:length(ind_unit_delay)
            comp_port_type = get_param(stateBlockPath(ind_unit_delay(ct)),'CompiledPortDataTypes');
            if ~strcmp(comp_port_type{1}.Inport,'double')
                ind_unit_delay_nondouble = [ind_unit_delay_nondouble;ind_unit_delay(ct)];
            end
        end

        % Find the discrete integrators that are of non-double data typed
        ind_disc_int = find(strcmp('DiscreteIntegrator',BlockTypes));
        ind_disc_int_nondouble = [];
        for ct = 1:length(ind_disc_int)
            comp_port_type = get_param(stateBlockPath(ind_disc_int(ct)),'CompiledPortDataTypes');
            if ~strcmp(comp_port_type{1}.Inport,'double')
                ind_disc_int_nondouble = [ind_disc_int_nondouble;ind_disc_int(ct)];
            end
        end

        nondouble_states = [ind_rate_transition(:);...
            ind_unit_delay_nondouble(:);ind_disc_int_nondouble(:)];
        stateBlockPath(nondouble_states) = [];
        
        % Now find the ordering of the states in the Jacobian relative to
        % the state structure.
        StructureStateOrder = {this.statestructure.signals.blockName};
        [unused,ix] = unique(StructureStateOrder);
        StructureStateOrder = StructureStateOrder(sort(ix));
%         % Find the blocks that are returned from the Jacobian calculation that are
%         % model references.  These are the states in the model references that need
%         % to be matched up with the state structure order.
%         for ct = numel(stateBlockPath):-1:1
%             BlockTypes{ct} = get_param(getBlockPath(slcontrol.Utilities,stateBlockPath{ct}),'BlockType');
%         end
%         MdlBlocks = unique(stateBlockPath(strcmp(BlockTypes,'ModelReference')));
%         % Using the MdlBlocks replace the values in the structure order with the
%         % names of the states returned from the Jacobian calculation.
%         for ct = 1:numel(MdlBlocks)
%             BlockInd = find(strncmp(StructureStateOrder,MdlBlocks{ct},numel(MdlBlocks{ct})));
%             StructureStateOrder(BlockInd) = repmat(MdlBlocks(ct),numel(BlockInd),1);
%         end
%         [unused,ix] = unique(StructureStateOrder);
%         StructureStateOrder = StructureStateOrder(sort(ix));
        xind = [];
        % Loop over the state names returned from the Jacobian data structure
        for ct = 1:length(StructureStateOrder)
            stateind = find(strcmp(StructureStateOrder(ct),stateBlockPath));
            xind = [xind;stateind];
        end
    else
        xind = [];nondouble_states = [];
    end
    uind = [];
    InputPointBlocks = this.InputPointBlocks;
    InputNames = J.Mi.InputName;
    % Loop over the state objects
    for ct = 1:length(InputPointBlocks)
        inputind = find(strcmp(InputPointBlocks(ct),InputNames));
        uind = [uind;inputind];
    end
    yind = [];
    OutputPointBlocks = this.OutputPointBlocks;
    OutputNames = J.Mi.OutputName;
    
    % Loop over the state objects
    for ct = 1:length(OutputPointBlocks)
        outputind = find(strcmp(OutputPointBlocks(ct),OutputNames));
        yind = [yind;outputind];
    end
    % Compute the offset perturbation to handle the computation of the
    % discrete Jacobian.  The Jacobian for the discrete states is 
    % x(k+1)-x(k) = f(x)-x(k) = g(x) which gives a dg/dx = df/dx - 1.
    discrete_state_offset = blkdiag(zeros(this.ncstates,this.ncstates),eye(numel(xind)-this.ncstates,numel(xind)-this.ncstates));
    % Store this vector for later use
    this.JacobianSortVectors = struct('xind',xind,'uind',uind,'yind',yind,...
                                      'discrete_state_offset',discrete_state_offset,...
                                      'nondouble_states',nondouble_states);
end

% Remove the states not being trimmed
nondouble_states = this.JacobianSortVectors.nondouble_states;
a(nondouble_states,:) = [];
a(:,nondouble_states) = [];
b(nondouble_states,:) = [];
c(:,nondouble_states) = [];

% Get the interconnection matrices
M = J.Mi;

P = speye(size(d,1)) - d*M.E;
Q = P \ c;
R = P \ d;

% Close the LFT
A = a + b * M.E * Q;
B = b * (M.F + M.E * R * M.F);
C = M.G * Q;
D = M.H + M.G * R * M.F;

% Reorder the states
xind = this.JacobianSortVectors.xind;
uind = this.JacobianSortVectors.uind;
yind = this.JacobianSortVectors.yind;
A = A(xind,xind)-this.JacobianSortVectors.discrete_state_offset;
B = B(xind,:);
B = B(:,uind);
C = C(:,xind);
C = C(yind,:);
D = D(:,uind);
D = D(yind,:);

% Now find which rows in C and D should be removed because the output
% constraint is met by an upper and lower bound.
ind = (this.F_y == 0);

if ~isempty(ind) && ~isempty(this.iy)
    % Create a boolean vector of outputs that are not fixed at a value.
    ind_free = true(size(ind));
    ind_free(this.iy) = false;
    
    % Blast the rows
    C(ind | ind_free,:) = 0;
    D(ind | ind_free,:) = 0;
elseif ~isempty(ind) && isempty(this.iy)
    % Blast the rows
    C(ind,:) = 0;
    D(ind,:) = 0;
end
