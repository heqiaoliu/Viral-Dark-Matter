function this = STPortID(Name,Dimension,Path,Type) 
% STPORTID  constructor for SISOTOOL port object
%
% h = modelpack.STPortID(Name,Dimension,[Path],[Type]) 
%
% Inputs:
%   Name      - string with port name
%   Dimension - double vector with port dimensions
%   Path      - string with path to port
%   Type      - string with port type, valid types {'Input'|'Output'}
%

% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/09/18 02:29:04 $

%Instantiate object
this = modelpack.STPortID;

% No argument constructor call
if nargin == 0, return, end

%Check number of arguments
if nargin < 2 || nargin > 4
   ctrlMsgUtils.error('SLControllib:modelpack:errNumArguments','5')
end

%Default arguments
if nargin < 3 || isempty(Path), Path = ''; end
if nargin < 4 || isempty(Type), Type = 'Output'; end

%Check input argument types
if ~any(strcmpi({'Input','Output'},Type))
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Type','{''Input''|''Output''}');
end

%Set properties
this.Version    = 1.0;
this.Name       = Name;
this.Path       = Path;
this.PortNumber = 1;
this.Dimension  = Dimension;
this.Type       = Type;
