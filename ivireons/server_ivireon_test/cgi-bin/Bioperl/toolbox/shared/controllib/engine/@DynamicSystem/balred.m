function rsys = balred(sys,orders,varargin)
%BALRED  Model order reduction.
%
%   RSYS = BALRED(SYS,ORDERS) computes a reduced-order approximation RSYS 
%   of the LTI model SYS. The desired order (number of states) for RSYS 
%   is specified by ORDERS. You can try multiple orders at once by setting 
%   ORDERS to a vector of integers, in which case RSYS is an array of 
%   reduced-order models. When SYS has unstable poles, it is first 
%   decomposed into its stable and unstable parts using STABSEP, and only 
%   the stable part is reduced.
%
%   RSYS = BALRED(SYS,ORDERS,BALDATA) makes use of the balancing data
%   BALDATA computed by HSVD. Because HSVD does most of the work needed to
%   compute RSYS, this syntax is more efficient when using HSVD together 
%   with BALRED.
%
%   SYS = BALRED(SYS,ORDERS,...,OPTIONS) specifies additional options for
%   the stable/unstable decomposition and state elimination. Use 
%   BALREDOPTIONS to create and configure the option set OPTIONS.
%
%   BALRED uses implicit balancing techniques to compute the reduced-order 
%   approximation RSYS.  Use HSVD to plot the Hankel singular values and 
%   pick an adequate approximation order. States with relatively small 
%   Hankel singular values can be safely discarded.
%
%   See also BALREDOPTIONS, HSVD, ORDER, MINREAL, SS/SMINREAL.

%	Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:31 $
ni = nargin-2;
if ni<0
   ctrlMsgUtils.error('Control:general:TwoOrMoreInputsRequired','balred','balred')
elseif numsys(sys)~=1
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','balred')
elseif any(iosize(sys)==0)
   % System without input or output
   ctrlMsgUtils.error('Control:transformation:NotSupportedNoInputsorOutputs','balred')
end

% Parse input list
BalData = [];
if ni>0 && isstruct(varargin{1})
   BalData = varargin{1};  varargin = varargin(2:ni);  ni = ni-1;
end
if ni>0 && isa(varargin{1},'ltioptions.balred')
   Options = varargin{1};
else
   % Handle pre-R2010a syntax:
   % balred(sys,orders,'AbsTol',ATOL,'RelTol',RTOL,'Offset',ALPHA,'Elimination',METHOD,'Balancing',BALDATA)
   idx = find(strncmpi(varargin,'b',1),1);
   if ~isempty(idx) && idx<ni
      BalData = varargin{idx+1};  varargin(:,[idx idx+1]) = [];
   end
   try
      Options = balredOptions(varargin{:});
   catch ME
      throw(ME)
   end
end

% Validate BALDATA
if ~isempty(BalData)
   if isstruct(BalData) && ~isfield(BalData,'ZeroTol')
      % ZeroTol added in R2007a
      try  %#ok<TRYNC>
         BalData.ZeroTol = eps * max([0;BalData.g(BalData.Split(1)+1:end)]);
      end
   end      
   if ~(isstruct(BalData) && ...
         isequal(fieldnames(BalData),{'Split';'as';'bs';'cs';'t';'Rr';'Ro';'u';'v';'g';'d';'ZeroTol'}))
      ctrlMsgUtils.error('Control:transformation:balred1')
   end
end

% Validate specified orders
orders = orders(:);
if isempty(orders) || ~(isnumeric(orders) && isreal(orders) && all(rem(orders,1)==0 & orders>=0))
   ctrlMsgUtils.error('Control:transformation:balred2')
end

% Clear notes, userdata, etc
sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];

% Perform reduction
try
   rsys = balred_(sys,orders,BalData,Options);
catch E
   ltipack.throw(E,'command','balred',class(sys))
end
