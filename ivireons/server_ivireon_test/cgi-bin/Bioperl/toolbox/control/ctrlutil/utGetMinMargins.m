function [Gm,Pm,Dm,Wcg,Wcp,isStable] = utGetMinMargins(varargin)
% Utility to derive min. stability margins from ALLMARGIN's output.
% utGetMinMargins(s) where s is the stability margin structure returned
%      from all margin
% utGetMinMargins(Gm,Pm,Dm,Wcg,Wcp)

%   Author(s): P. Gahinet 
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/01/26 01:48:36 $

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
    [junk,imin] = min(aux);
    Gm = GmData(imin);
    Wcg = GMFrequency(imin);
end

% Compute min phase margin
if isempty(PmData)
   Pm = Inf;
   Dm = Inf;
   Wcp = NaN;
else
   [junk,idx] = min(abs(PmData));
   Pm = PmData(idx);
   Dm = DmData(idx);
   Wcp = PMFrequency(idx);
end


