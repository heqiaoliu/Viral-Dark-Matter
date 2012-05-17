function c = eval(this,Sys)
% EVAL method to evaluate nicholslocation requirement for a given system
%
% Inputs:
%          this - a srorequirement.nicholslocation object.
%          Sys  - An n-by-1  vector of Sys structures
% Outputs: 
%          c - an n-by-1 matrix of doubles giving the maximum signed distance 
%          of each signal to each edge of the requirement. A negative value 
%          indicates a feasible point.
 
% Author(s): A. Stothert 31-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:16 $

c = [];
if isempty(Sys)
   return
end

if isfield(Sys,'Model')
   Model = Sys.Model; 
   FreqResponse = Sys.FreqResponse;
else
   Model = Sys;
   FreqResponse = [];
end

%Number of responses
nSys = prod(size(Model)); %#ok<PSIZE>

%Retrieve constraint data
nEdge = this.Data.getEdgeCount + 2;

if isempty(FreqResponse)
   %Need to compute frequency data, store data so can potentially reuse
   [rV,iV,w] = nyquist(Model);
   rV = localReshape(rV); 
   iV = localReshape(iV);
   FreqResponse = struct('real',rV,'imag',iV,'freq',w);
   FR = FreqResponse.real+1i*FreqResponse.imag;
else
   %Have frequency data 
   FR = Sys.FreqResponse.real+1i*Sys.FreqResponse.imag;
end

%Compute magnitude and phase form frequency data
mag = abs(FR);
phs = unwrap(angle(FR));
if this.FeedbackSign == 1
   phs = phs + pi;
end

%Perform any unit conversions
if strcmpi(this.Data.getData('xUnits'),'deg')
   phs = unitconv(phs,'rad','deg');
end
if strcmpi(this.Data.getData('yUnits'),'db')
   mag = unitconv(mag,'abs','db');
end

c = nan(nEdge,nSys);
for ct = 1:nSys
   %Find closest signed distance of each point on Nichols curve to each edge.
   minD = this.minDistance([phs(:,ct),mag(:,ct)],true);
   %Find closest distance to each edge
   c(:,ct) = max(minD,[],2);
end

%Only keep track of closest infeasible or feasible point
c = sign(c(1,:)).*min(abs(c),[],1);

%--------------------------------------------------------------------------
function x = localReshape(x)
%Helper function to convert output from Nyquist to columns of data

x = reshape(permute(x,[3 1 2]),size(x,3),size(x,2)*size(x,1));
