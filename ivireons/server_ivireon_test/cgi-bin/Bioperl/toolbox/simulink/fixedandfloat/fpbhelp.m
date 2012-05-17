function fpbhelp(blkname)
% FPBHELP Points Web browser to the HTML help file
%          corresponding to Simulink Fixed-Point.

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.19.2.6 $ 
% $Date: 2009/11/13 05:05:21 $
d = docroot;
           
if isempty(d)
    % Help system not present:
    warning('fpbhelp:NoDocRootFound', ...
            'Could not locate docroot. Type help docroot to configure your documentation settings');
    helpview(fullfile(docroot, 'toolbox', 'fixpoint', 'fixpoint.map'), 'fp_product_page');
else
    if isempty(blkname) || isequal(blkname,'fxptdlg')
        if ~isempty(which('autofixexp')) % Locates if Simulink Fixed-Point is installed
            helpview(fullfile(docroot, 'mapfiles', 'simulink.map'), 'f11-xptdlg');
        else
            helpview(fullfile(docroot, 'mapfiles', 'simulink.map'), 'f14-p_settings_dialog');
        end
    else
        helpview(fullfile(docroot, 'toolbox', 'fixpoint', 'fixpoint.map'), 'fp_product_page');        
    end
end

