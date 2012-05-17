function this = ltisource(model,varargin)
%LTISOURCE  Constructor for @ltisource class

%  Author(s): Bora Eryilmaz
%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:27 $

% Create class instance
this = resppack.ltisource;

% Initialize attributes
this.Model = model;

% Initialize cache
Nresp = getsize(this,3);
this.Cache = struct(...
   'Stable',cell(Nresp,1),...
   'MStable',cell(Nresp,1),...
   'DCGain',cell(Nresp,1),...
   'Margins',cell(Nresp,1));

% Add listeners
addlisteners(this)

% Set additional parameters in varargin
if ~isempty(varargin)
   set(this,varargin{:});
end

