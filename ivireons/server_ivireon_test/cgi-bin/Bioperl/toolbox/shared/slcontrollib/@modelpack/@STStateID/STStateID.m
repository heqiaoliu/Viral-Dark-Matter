function this = STStateID(Name,Dimension,Path,Ts) 
% STSTATEID  constructor for SISOTOOL state object
%
% h = modelpack.STStateID(Name,Dimension,[Path],[Ts]) 
%
% Inputs:
%   Name      - string with state name
%   Dimension - double vector with dimensions of state
%   Path      - string with path to state
%   Ts        - double with state sampling period, zero, implies continuous
%

% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/09/18 02:29:08 $

%Instantiate object
this = modelpack.STStateID;

% No argument constructor call
if nargin == 0, return, end

%Check number of arguments
if nargin < 2 || nargin > 4
   cltrMsgUtils.error('SLControllib:modelpack:errNumArguments','4')
end

%Default arguments
if nargin < 3 || isempty(Path), Path = ''; end
if nargin < 4 || isempty(Ts),   Ts   = 0; end

%Check input argument types
if ~isnumeric(Ts) || ~isscalar(Ts) || ~isfinite(Ts) || Ts < 0
   ctrlMsgUtils.error('SLControllib:modelpack:stErrorFinitePositive','Ts')
end

%Set properties
this.Version   = 1.0;
this.Name      = Name;
this.Path      = Path;
this.Dimension = Dimension;
this.Ts        = Ts;
