function can_msg_id_check(id, msg_type)
%CAN_MSG_ID_CHECK checks for a valid CAN message identifier
%  Checks if the specified message identifier and message type are valid
%
%  CAN_MSG_ID_CHECK(ID, MSG_TYPE) takes a numeric identifier ID, e.g. '51' or
%  hex2dec('100') and MSG_TYPE, which must be either 1 for Standard (11-bit 
%  identifier) or 2 for Extended (29-bit identifier). If ID is 
%  is an integer in the valid range the function returns successfully.
%  If any of the checks fails an error is generated.
%
%  See also 

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%   $Date: 2007/11/13 00:13:07 $
  
  if ischar(id)
    TargetCommon.ProductInfo.error('can', 'CANInvalidMsgId');
  end
  
  if length(id) > 1
    TargetCommon.ProductInfo.error('can', 'CANInvalidMsgIdTypeVector');
  end
    
  switch msg_type
   case 1 % 'Standard (11-bit identifier)'
    if floor(id)~=id | id<0 | id>=2^11
      TargetCommon.ProductInfo.error('can', 'CANInvalidMsgIdShort', num2str(id));
    end
      case 2 % 'Extended (29-bit identifier)'
       if floor(id)~=id | id<0 | id>=2^29
         TargetCommon.ProductInfo.error('can', 'CANInvalidMsgIdLong', num2str(id));
       end
    otherwise
      TargetCommon.ProductInfo.error('can', 'CANInvalidMsgType', num2str(msg_type));
  end
     
     
