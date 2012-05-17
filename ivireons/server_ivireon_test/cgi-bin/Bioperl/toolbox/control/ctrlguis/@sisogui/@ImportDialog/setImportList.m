function setImportList(this)
% setImportList  Sets the list of models can be imported
%   Plant can not be imported for config 0
%   TunedMasked object can not be imported 

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/01/26 01:47:15 $

Design = this.Design;

ImportList = [];

% Do not used fixed elements for SCD
if Design.Configuration ~= 0
    % Add Fixed components
    ImportList = Design.Fixed;
end

% For compensators only use TunedZPK elements that are unconstrained
Tuned = Design.Tuned;
for ct = 1:length(Tuned)
    if isa(Design.(Tuned{ct}),'sisodata.TunedZPKSnapshot') && ~LocalIsConstrained(Design.(Tuned{ct}))
        ImportList = [ImportList(:); Tuned(ct)];
    end
end

this.ImportList = ImportList;

        
    
function boo = LocalIsConstrained(this)
% Checks if compensator has constraints
Constraints = this.getProperty('Constraints');
FixedDynamics = this.getProperty('FixedDynamics');
boo = false;
if ~isempty(Constraints) && (isfinite(Constraints.MaxZeros) || isfinite(Constraints.MaxPoles) || ...
    ~(isempty(FixedDynamics) || isstatic(FixedDynamics)))
    boo = true;
end