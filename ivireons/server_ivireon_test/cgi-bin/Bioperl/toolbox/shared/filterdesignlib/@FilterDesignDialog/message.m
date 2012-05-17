function msg = message(id, varargin)
%MESSAGE  Message generates the message from the xlate file
%   MES = MESSAGE(ID) 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/07 20:44:44 $

% Build up the ID.
if iscell(id)
    msg = cell(size(id));
    for indx = 1:numel(id)
        msg{indx} = FilterDesignDialog.message(id{indx}, varargin{:});
    end
    return;
end

% Work around issues with invalid characters in message identifiers.
% Unfortunately message IDs here are tangled up with user interface
% valid parameters etc. so it's not a straightforward fix to get the
% invalid characters out of the message IDs.
%
id = strrep(id,'.','');
id = strrep(id,' ','');
id = strrep(id,'-','_');
id = strrep(id,'/','_');

id = ['FilterDesignLib:FilterDesignDialog:fb' id];

% Get the Message catalog object.
mObj = MessageID(id);

% Get the individual message.
msg  = message(mObj, varargin{:});

% [EOF]
