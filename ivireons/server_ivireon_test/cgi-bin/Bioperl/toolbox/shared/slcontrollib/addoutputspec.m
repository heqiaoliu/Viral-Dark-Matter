function opnew = addoutputspec(op,block,portnumber)
% ADDOUTPUTSPEC Add output specification to operating point specification
%
%   OPNEW=ADDOUTPUTSPEC(OP,'block',PORTNUMBER) adds an output specification 
%   for a Simulink model to an existing operating point specification, OP, 
%   created with OPERSPEC. The signal being constrained by the output 
%   specification is indicated by the name of the block, 'block', and the 
%   port number, PORTNUMBER, that it originates from. You can edit the 
%   output specification within the new operating point specification 
%   object, OPNEW, to include the actual constraints or specifications for 
%   the signal. Use the new operating point specification object with the 
%   function FIDNOP to find operating points for the model. 
%
%   This function will automatically compile the Simulink model, given in 
%   the property Model of OP, to find the block's output portwidth.
%
%   See also OPERSPEC.

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2010/04/30 00:39:59 $

% Input checking
error(nargchk(3, 3, nargin, 'struct'))

% Create the new output constraint object
newoutput = opcond.OutputSpec;

% Compile the model to get the compiled portwidths
isclosed = isempty(find_system('SearchDepth',0,'CaseSensitive','off',...
        'Name',op.Model));
simstat = false;
if isclosed || strcmp(get_param(op.Model,'SimulationStatus'),'stopped')
    simstat = true;    
    % The model must be in normal mode to query
    want = struct('SimulationMode', 'normal');
    ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(op.Model);
    ModelParameterMgr.loadModels;
    ModelParameterMgr.ModelParameters = want;
    ModelParameterMgr.prepareModels;
    feval(op.Model,[],[],[],'lincompile');
end

% Set the properties
newoutput.Block = block;
newoutput.PortNumber = portnumber;
update(newoutput);

% Terminate the compilation
if simstat
    feval(op.Model,[],[],[],'term')
    % Return the model to its previous context
    ModelParameterMgr.restoreModels;
    ModelParameterMgr.closeModels;
end

% Create a copy of the operating condition spec
opnew = copy(op);

% Store the output in the OperatingSpec object
opnew.Outputs = [opnew.Outputs;newoutput];
