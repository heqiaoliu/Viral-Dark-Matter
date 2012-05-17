function splitEdge(this,iElement,SplitType)

%   Author: A. Stothert 
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:46 $

%Only split if have valid constraint
if ~this.isValid
   return
end

%If no split edge specified use selected edge
if nargin < 2, iElement = this.SelectedEdge; end
%If no split type is specified use linear
if nargin < 3, SplitType = {'linear', 'linear'}; end

linMidPoint = @(x) 0.5*sum(x);
logMidPoint = @(x) sqrt(prod(x));
switch SplitType{1}
   case 'log'
      midX = logMidPoint(this.xCoords(iElement,:));
   otherwise
      midX = linMidPoint(this.xCoords(iElement,:));
end
switch SplitType{2}
   case 'log'
      midY = logMidPoint(this.yCoords(iElement,:));
   otherwise
      midY = linMidPoint(this.yCoords(iElement,:));
end

%Insert coordinates for new edge
this.xCoords = [...
   this.xCoords(1:iElement-1,:); ...
   [this.xCoords(iElement,1), midX ]; ...
   [midX, this.xCoords(iElement,2)]; ...
   this.xCoords(iElement+1:end,:)];
this.yCoords = [...
   this.yCoords(1:iElement-1,:); ...
   [this.yCoords(iElement,1), midY ]; ...
   [midY, this.yCoords(iElement,2)]; ...
   this.yCoords(iElement+1:end,:)];

%Update Linked elements
this.Linked = [...
   this.Linked(1:iElement-1,:); ...
   [false, false]; ...
   this.Linked(iElement:end,:)];
%Update weight vector
this.Weight = [...
   this.Weight(1:iElement-1); ...
   this.Weight(iElement); ...
   this.Weight(iElement:end)];

%Notify listeners of data source change
this.send('DataChanged');

