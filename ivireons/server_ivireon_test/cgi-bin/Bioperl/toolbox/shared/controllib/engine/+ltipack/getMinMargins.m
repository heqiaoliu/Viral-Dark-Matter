function [Gm,Pm,Dm,Wcg,Wcp,isStable] = getMinMargins(varargin)
% Utility to derive min. stability margins from ALLMARGIN's output.
% 
%     ltipack.getMinMargins(s) (s = output of ALLMARGIN)
%     ltipack.getMinMargins(Gm,Pm,Dm,Wcg,Wcp)

%   Author(s): P. Gahinet 
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:47 $
if nargin == 1 
    % assume struct from allmargin
    s = varargin{1};
    GmData = s.GainMargin;
    PmData = s.PhaseMargin;
    DmData = s.DelayMargin;
    GMFrequency = s.GMFrequency;
    PMFrequency = s.PMFrequency;
    % Stability flag
    isStable = s.Stable;
else
    GmData = varargin{1};
    PmData = varargin{2};
    DmData = varargin{3};
    GMFrequency = varargin{4};
    PMFrequency = varargin{5};
    isStable = NaN;
end
    

% Compute min (worst-case) gain margin
if isempty(GmData)
    Gm = Inf;
    Wcg = NaN;
else
    % RE: watch for log of zero
    aux = inf(size(GmData));
    ipos = find(GmData>0);
    aux(ipos) = abs(log2(GmData(ipos)));
    [~,imin] = min(aux);
    Gm = GmData(imin);
    Wcg = GMFrequency(imin);
end

% Compute min phase margin
if isempty(PmData)
   Pm = Inf;
   Dm = Inf;
   Wcp = NaN;
else
   [~,idx] = min(abs(PmData));
   Pm = PmData(idx);
   Dm = DmData(idx);
   Wcp = PMFrequency(idx);
end
