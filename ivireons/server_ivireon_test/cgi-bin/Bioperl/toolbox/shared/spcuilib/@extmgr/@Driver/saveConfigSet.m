function [saved, cfgFile] = saveConfigSet(this, cfgFile)
%SAVECONFIGSET Save current extension configuration properties.
%   SAVECONFIGSET(H) saves the current configuration properties in the last
%   saved or loaded file.  If no configuration file has been saved or
%   loaded in the session, a dialog will open to specify the location of
%   the configuration file.
%
%   SAVECONFIGSET(H, FNAME) saves the current configuration properties in
%   the file specified by FNAME.

% Saves the ConfigDb database, not the ScopeCfg
% We don't retain scope position, docking, etc, in a config set
% (That's the business of an instrument set!)

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/05/23 19:03:34 $

if nargin < 2
    cfgFile = get(this, 'LastAccessedFile');
end

% If we have a file name, pass it directly to saveConfigSetAs, otherwise
% call with no additional inputs and a dialog will be launched.
if isempty(cfgFile)
    [saved, cfgFile] = saveConfigSetAs(this);
else
    [saved, cfgFile] = saveConfigSetAs(this, cfgFile);
end

% [EOF]
