function sync_script_data()
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/21 01:06:08 $

emlScripts = sf('find','all','~script.script',[]);
for j = 1:length(emlScripts)
    eml_man('update_data', emlScripts(j));
    eml_man('refresh_editor', emlScripts(j));
end
