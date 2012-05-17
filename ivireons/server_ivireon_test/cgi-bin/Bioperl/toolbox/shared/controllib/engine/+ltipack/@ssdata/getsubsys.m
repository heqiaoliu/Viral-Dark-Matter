function [Dsub,xkeep] = getsubsys(D,rowIndex,colIndex,varargin)
% Extracts subsystem.
%
%    Dsub = getsubsys(D,rowIndex,colIndex) extracts the subsystem 
%    sys(rowIndex,colIndex). Dsub and D have the same number of 
%    states.
%
%    [Dsub,xkeep] = getsubsys(D,rowIndex,colIndex,'smin') further
%    eliminates states that are structurally decoupled from the
%    subsystem. The boolean vector XKEEP indicates which states
%    were kept and which states were discarded.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:08 $

% NOTE: Don't systematically reduce the state dim. with SMREAL.
% This messes up applications like LQG design where gain and 
% estimators need to be designed with same number of states, cf
% MILLDEMO.
MinFlag = (nargin>3);

% Delays
Delay = D.Delay;
Delay.Input = Delay.Input(colIndex,:);  % colon needed if scalar and colIndex=[1 1]
Delay.Output = Delay.Output(rowIndex,:);

% Factor in internal delays
nfd = length(Delay.Internal);
e = D.e;
StateName = D.StateName;
StateUnit = D.StateUnit;
if nfd==0
   % No internal delays
   d = D.d(rowIndex,colIndex);
   if MinFlag && ~isempty(D.a)
      % Structurally minimal state realization requested (skip if A=[])
      [a,b,c,e,xkeep] = ...
         smreal(D.a,D.b(:,colIndex),D.c(rowIndex,:),e);
      if ~isempty(StateName)
         StateName = StateName(xkeep,:);
      end
      if ~isempty(StateUnit)
         StateUnit = StateUnit(xkeep,:);
      end
   else
      % Structurally minimal realization wrt delays
      a = D.a;
      b = D.b(:,colIndex);
      c = D.c(rowIndex,:);
      xkeep = true(size(D.a,1),1);
   end
else
   % Account for internal delays
   [nr,nc] = size(D.d);
   ny = nr-nfd;
   nu = nc-nfd;
   nx = size(D.a,1);
   
   % Map ROWINDEX and COLINDEX to integer indices into D.d
   if ischar(rowIndex),
      rowIndex = 1:ny;
   elseif isa(rowIndex,'logical'),
      rowIndex = find(rowIndex);  
   end
   if ischar(colIndex),
      colIndex = 1:nu;
   elseif isa(colIndex,'logical'),
      colIndex = find(colIndex);  
   end

   % Compute structurally minimal realization wrt both states and delays
   % RE: Not enough to look just at delay realization (d22,[d21,c2],[d12;b2])
   if isempty(e)
      E = [];
   else
      E = blkdiag(e,eye(nfd));
   end
   [A,B,C,E,xdkeep] = smreal(...
      [D.a D.b(:,nu+1:nc);D.c(ny+1:nr,:) D.d(ny+1:nr,nu+1:nc)],...
      [D.b(:,colIndex) ; D.d(ny+1:nr,colIndex)],...
      [D.c(rowIndex,:) , D.d(rowIndex,nu+1:nc)] , E);
   xkeep = xdkeep(1:nx);
   ns = sum(xkeep);
   dkeep = xdkeep(nx+1:nx+nfd);
   nd = sum(dkeep);
   if MinFlag
      % Eliminate nonminimal states and nonminimal delays
      a = A(1:ns,1:ns);
      if ~isempty(e)
         e = E(1:ns,1:ns);
      end
      b = [B(1:ns,:) A(1:ns,ns+1:ns+nd)];
      c = [C(:,1:ns) ; A(ns+1:ns+nd,1:ns)];
      d = [D.d(rowIndex,colIndex) C(:,ns+1:ns+nd) ; ...
            B(ns+1:ns+nd,:) A(ns+1:ns+nd,ns+1:ns+nd)];
      if ~isempty(StateName)
         StateName = StateName(xkeep,:);
      end
      if ~isempty(StateUnit)
         StateUnit = StateUnit(xkeep,:);
      end
   else
      % Eliminate only nonminimal delays
      a = D.a;
      idxu = nu+1:nc;  idxu = idxu(dkeep);
      idxy = ny+1:nr;  idxy = idxy(dkeep);
      b = [D.b(:,colIndex) , D.b(:,idxu)];
      c = [D.c(rowIndex,:) ; D.c(idxy,:)];
      d = [D.d(rowIndex,colIndex) D.d(rowIndex,idxu) ; ...
            D.d(idxy,colIndex) D.d(idxy,idxu)];
   end
   Delay.Internal = Delay.Internal(dkeep,:);
end


% Create output
Dsub = ltipack.ssdata(a,b,c,d,e,D.Ts);
Dsub.StateName = StateName;
Dsub.StateUnit = StateUnit;
Dsub.Delay = Delay;

