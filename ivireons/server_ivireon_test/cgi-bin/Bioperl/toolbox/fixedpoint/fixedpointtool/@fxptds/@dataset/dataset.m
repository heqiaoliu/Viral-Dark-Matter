function this = dataset(varargin)
% DATASET constructor
%  

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/05 22:16:29 $

this = fxptds.dataset;
if nargin > 0 && isa(varargin{1},'Simulink.BlockDiagram')
    this.rootmdl = varargin{1};
end
if  this.isSDIEnabled
    this.SDIEngine = Simulink.sdi.SDIEngine;
    % Initialize the DataMap to contain a character key and an integer value.
    this.RunIDMap = Simulink.sdi.Map(char('a'), uint32(0)); 
    
    % Initialize the Map to store any Run related information.
    this.RunDataMap = Simulink.sdi.Map(uint32(0),?handle);
end
this.init;

% [EOF]
