function displayEndOfDemoMessage(filename)
%displayEndOfDemoMessage Explain how to get more information about a demo.
%   displayEndOfDemoMessage(mfilename) shows a link to the published HTML
%   version of an M-file written using cells.  Enable Cell Mode using the Cell
%   menu in the MATLAB Editor.
%
%   The message only displays when the file is run top-to-bottom.  When
%   publishing or evaluating as cells, this function does nothing.

% $Revision: 1.1.6.1 $  $Date: 2010/05/03 16:09:24 $
% Copyright 2005 The MathWorks, Inc.

% Check nargin explicitly, so we throw an error even in -nodesktop mode.
error(nargchk(1,1,nargin,'struct'))

% Do nothing unless:
if feature('hotlinks') && ... the caller wants links (PUBLISH doesn't)
        ~isempty(filename) && ... we're not in Cell Mode in the Editor
        ~strcmp(filename,'echodemo') ... we're in playback with ECHODEMO
    fprintf('\n');
    fprintf('\n');
    fprintf('-------------------------------------------------------------------------\n');
    fprintf('\n');
    fprintf(' <a href="matlab:showdemo %s">View the published version of this demo</a> to learn more about "%s.m".\n',filename,filename);
    fprintf('\n');
    fprintf('-------------------------------------------------------------------------\n');
    fprintf('\n');
end
