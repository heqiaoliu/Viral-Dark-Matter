function slprophelp(dialog_type)
%SLPROPHELP Displays the help for various Simulink dialogs boxes.
%   SLPROPHELP(DIALOG_TYPE) points the web browser to the Simulink
%   reference pages for the block properties, model properties, 
%   signal properties, or mask editor dialog boxes.
%
%   See also SLHELP

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.9.2.6 $  $Date: 2009/08/23 19:39:11 $

doc_path = docroot;
if isempty(doc_path)
  helpview([matlabroot,'/toolbox/local/helperr.html']);
  return;
end

doc_path = [doc_path '/mapfiles/simulink.map'];
switch dialog_type
  case 'model'
    helpview(doc_path, 'modelpropertiesdialog')

  case 'block'
    helpview(doc_path, 'blockpropertiesdialog')
  case 'sigandscopemgr'
    helpview([docroot '/mapfiles/simulink.map'], 'signal_and_scope_mgr');
  case 'signal'
    helpview(doc_path, 'signalpropertiesdialog')

  case 'state'
    rtw_ug_mapfile = fullfile(docroot, 'mapfiles', 'rtw_ug.map');
    if exist(rtw_ug_mapfile, 'file')
      helpview(rtw_ug_mapfile, 'rtw_block_states')
    else
      helpview(doc_path , 'statepropertiesdialog')
    end

  case 'maskeditor'
    helpview(doc_path, 'maskeditordialog')

  case 'buseditor'
    helpview(doc_path, 'bus_editor')

  case 'editedlinkstool'    
    helpview([docroot '/toolbox/simulink/ug/simulink_ug.map'], 'editedlinkstool');
    
  otherwise
    DAStudio.error('Simulink:dialog:SlprophelpInvalidProperty', dialog_type);
end

