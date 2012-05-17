function [H,H0,varargout] = modsep(G,N,varargin)
%MODSEP  Region-based modal decomposition.
%
%   [H,H0] = MODSEP(G,N,REGIONFCN) decomposes the LTI model G into a 
%   sum of N simpler models Hj with their poles in disjoint regions Rj
%   of the complex plane:
%
%      G(s) = H0 +  sum   Hj(s) ,     pole(Hj) inside Rj
%                  j=1:N
%
%   G can be any LTI model created with SS, TF, or ZPK, and N is the 
%   number of regions used in the decomposition.  MODSEP packs the 
%   submodels Hj into an LTI array H and returns the static gain H0 
%   separately.  Use H(:,:,j) to retrieve the submodel Hj(s).
%
%   To specify the regions of interest, use a function of the form
%      IR = REGIONFCN(P)
%   that assigns a region index IR between 1 and N to a given pole P.
%   You can specify this function as a string or a function handle, and
%   use the syntax MODSEP(G,N,REGIONFCN,PARAM1,...) to pass extra input 
%   arguments: IR = REGIONFCN(P,PARAM1,...).
%
%   Example
%     To decompose G into G(z) = H0 + H1(z) + H2(z) where H1 and H2 
%     have their poles inside and outside the unit disk respectively,
%     use 
%        [H,H0]  = modsep(G,2,@udsep)
%     where the function UDSEP is defined by
%        function r = udsep(p)
%        if abs(p)<1, r = 1;  % assign r=1 to poles inside unit disk
%        else         r = 2;  % assign r=2 to poles outside unit disk
%        end
%     To extract H1(z) and H2(z) from the LTI array H, use 
%        H1 = H(:,:,1);  H2 = H(:,:,2);
%
%   See also STABSEP, LTI, DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:36:47 $
no = nargout-2;
if numsys(G)~=1
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','modsep')
elseif N<=0
   ctrlMsgUtils.error('Control:transformation:modsep3')
elseif no>0 && ~isa(G,'StateSpaceModel')
   % Set T=Ti=[] for non-state-space models
   no = 0;  varargout = cell(1,2);
end

% Clear notes, userdata, etc
G.Name_ = [];  G.Notes_ = [];  G.UserData = [];

% Perform separation
try
   [H,H0,varargout{1:no}] = modsep_(G,N,varargin{:});
catch E
   ltipack.throw(E,'command','modsep',class(G))
end
