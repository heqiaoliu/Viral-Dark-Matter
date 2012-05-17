function Dr = modred(D,method,elim)
% Extracts reduced-order model.

%   Author(s): J.N. Little, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:26 $
ns = size(D.a,1);
if ns==0,
   Dr = D;  return
elseif hasInternalDelay(D)
   throw(ltipack.utNoDelaySupport('modred',D.Ts,'internal'))
end
keep = 1:ns;
keep(elim) = [];
nskeep = length(keep);
Ts = D.Ts;

try
   % REVISIT: generalize to descriptor
   [a,b,c,d] = getABCD(D);
catch %#ok<CTCH>
    ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','modred')
end

switch method
   case 'MatchDC'
      % Matched DC gains: partition into x1, to be kept, and x2, to be eliminated:
      xperm = [keep(:);elim(:)];
      if Ts~=0,
         % Discrete-time system: A22 -> A22-I
         a(elim,elim) = a(elim,elim) - eye(length(elim));
      end
      [ar,br,cr,dr,er] = elimAV(a(xperm,xperm),b(xperm,:),c(:,xperm),d,[],Ts,nskeep);
      
   case 'Truncate'
      % Simply delete specified states
      ar = a(keep,keep);
      br = b(keep,:);
      cr = c(:,keep);
      dr = d;
      er = [];
end

% Build output
Dr = ltipack.ssdata(ar,br,cr,dr,er,Ts);
Dr.Delay = D.Delay;
nxdiff = size(ar,1)-nskeep;
if ~isempty(D.StateName)
   Dr.StateName = [D.StateName(keep) ; repmat({''},nxdiff,1)];
end
if ~isempty(D.StateUnit)
   Dr.StateUnit = [D.StateUnit(keep) ; repmat({''},nxdiff,1)];
end

