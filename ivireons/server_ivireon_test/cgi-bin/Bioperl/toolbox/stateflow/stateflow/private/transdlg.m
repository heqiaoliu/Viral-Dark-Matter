

function varargout = transdlg(varargin)
%TRANSDLG  Creates and manages the transition dialog box

%   E.Mehran Mestchian January 1997
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.19.2.11 $  $Date: 2008/12/01 08:08:29 $


    objectId = varargin{2};
    dynamic_dialog_l(objectId);

function dynamic_dialog_l(transId)
  
  r = sfroot;
  type = sf('get', transId, '.type');
  
  
  if (type == 0) % SIMPLE wire
      idWithHandle = transId;
  elseif (type == 2) % SUPER wire
      idWithHandle = sf('get', transId, '.firstSubWire');
  else % SUB wire
      idWithHandle = transId;
      nextId = idWithHandle;
      while (nextId ~= 0)
          idWithHandle = nextId;
          nextId = sf('get', idWithHandle, '.subLink.before');
      end
  end
		
  h = r.idToHandle(idWithHandle);

  if ~isempty(h)		
        d = DAStudio.Dialog(h, 'State', 'DLG_STANDALONE');
        sf('SetDynamicDialog', idWithHandle, d);
  end
    
  
