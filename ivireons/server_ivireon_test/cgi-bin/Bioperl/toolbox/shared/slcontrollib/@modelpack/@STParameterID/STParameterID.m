function this = STParameterID(UniqueName,Dimension,Path, Class, Locations, Name) 
% STPARAMETERID  constructor for SISOTOOL parameter object
%
% h = modelpack.STParameterID(UniqueName,Dimension,[Path], [Class], [Locations], [Name])
%
% Inputs:
%   UniqueName - string with the uniquename of the parameter
%   Dimension  - double vector with dimensions of parameter
%   Path       - string with path to parameter
%   Class      - string with class of parameter
%   Locations  - string vector with locations where parameter is used
%   Name       - string with parameter name
%

% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/09/18 02:28:58 $

%Instantiate object
this = modelpack.STParameterID;

% No argument constructor call
if nargin == 0, return, end

%Check number of arguments
if nargin < 2 || nargin > 6
   ctrlMsgUtils.error('SLControllib:modelpack:errNumArguments','2 to 5')
end

%Set default arguments
if nargin < 3 || isempty(Path),       Path       = ''; end
if nargin < 4 || isempty(Class),      Class      = 'double'; end
if nargin < 5 || isempty(Locations),  Locations  = {}; end
if nargin < 6 || isempty(Name),       Name       = UniqueName; end

%Set properties
this.Version    = 1.0;
this.UniqueName = UniqueName;
this.Name       = Name;
this.Path       = Path;
this.Dimension  = Dimension;
this.Locations  = Locations;
this.Class      = Class;
 
   


