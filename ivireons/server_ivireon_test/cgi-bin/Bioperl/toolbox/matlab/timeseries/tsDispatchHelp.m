function tsDispatchHelp(mapkey,varargin)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

map_path = fullfile(docroot,'techdoc','time_series_csh','time_series_csh.map');
if nargin>=2 && strcmp(varargin{1},'modal')
    if nargin>=3 
        helpview(map_path,mapkey,'CSHelpWindow','size',[500 400],varargin{2});
    else
        helpview(map_path,mapkey,'CSHelpWindow','size',[500 400]);
    end
else
    helpview(map_path,mapkey,'size',[500 400]);
end
