function setconfig(this,ConfigID,LoopSign)
% Sets plant configuration

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/06/20 20:00:43 $

% New G components should be initialized when data is already loaded
InitFlag = ~isempty(this);

% Set up desired loop configuration
switch ConfigID
   case {1 2 3 4}
      % Single loop with 
      %   * Fixed models G, H
      %   * Compensator C in forward or feedback path
      %   * Prefilter or feedforward F
      this.nLoop = 2;
      LocalCreateModels(this,2,InitFlag)
      this.G(1).Identifier = 'G';
      this.G(1).Description = 'Plant';
      this.G(2).Identifier = 'H';
      this.G(2).Description = 'Sensor';
    case 5
      this.nLoop = 2;
      LocalCreateModels(this,3,InitFlag)
      this.G(1).Identifier = 'G1';
      this.G(1).Description = 'Plant';
      this.G(2).Identifier = 'G2';
      this.G(2).Description = 'Plant2';
      this.G(3).Identifier = 'Gd';
      this.G(3).Description = 'Disturbance Dynamics';
    case 6
      this.nLoop = 3;
      LocalCreateModels(this,4,InitFlag)
      this.G(1).Identifier = 'G1';
      this.G(1).Description = 'Plant';
      this.G(2).Identifier = 'G2';
      this.G(2).Description = 'Plant2';
      this.G(3).Identifier = 'H1';
      this.G(3).Description = 'Sensor';
      this.G(4).Identifier = 'H2';
      this.G(4).Description = 'Sensor2';
      
end

% RE: All feedback junctions are closed by default
this.LoopSign = LoopSign;
this.LoopStatus = true(size(LoopSign)); 

% Config data
this.Configuration = ConfigID;
this.Connectivity = this.loopIC(ConfigID,LoopSign);

% Clear dependencies
this.P = [];
this.Psim = [];

%---------------- Local Functions -------------------------

function LocalCreateModels(this,nG,InitFlag)
% Adjust the lists of fixed and tuned models
nG0 = length(this.G);
if nG0>nG,
   delete(this.G(nG+1:nG0));
   this.G = this.G(1:nG);
else
   for ct=nG0+1:nG
      G = sisodata.fixedmodel;
      if InitFlag
         G.import(struct('Name','','Value',zpk(1),'Variable',''))
      end
      this.G = [this.G ; G];
   end
end
