%TARGETSCOMMS_EXTERNALMODECCPWITHBLOCK class used for External Mode CCP with driver block
%   TARGETSCOMMS_EXTERNALMODECCPWITHBLOCK class used for External Mode CCP with
%   driver block

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/13 00:14:09 $

classdef TargetsComms_ExternalModeCCPWithBlock < TargetsComms_ExternalModeCCP

  properties(GetAccess = 'protected', SetAccess = 'protected')
    modelName;
    blkSearchExpr;
  end % properties(GetAccess = 'private', SetAccess = 'private')

  methods

    function this = TargetsComms_ExternalModeCCPWithBlock(varargin)
      import('com.mathworks.toolbox.ecoder.canlib.ccp.*');
      import('com.mathworks.toolbox.ecoder.canlib.ccp.vectorcan.*');
      import('com.mathworks.toolbox.ecoder.canlib.vector.*');
      
      % Define constructors
      sigs{1} = {'modelName' 'numEventChannels'};

      % Parse arguments
      args = targets_parse_argument_pairs(sigs{end}, varargin);

      n = targets_find_signature(sigs, args);

      % Constructor functions
      switch n
        case 1
          superArgs = {'numEventChannels', args.numEventChannels};
        otherwise
          error('TargetsComms_ExternalModeCCPWithBlock:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end
      % call super class constructor
      this@TargetsComms_ExternalModeCCP(superArgs{:});
      % init properties
      this.modelName = args.modelName;
      % Search the model for a CCP block
      blk = find_system(this.modelName, 'FollowLinks', 'on', 'LookUnderMasks', 'on', 'Regexp', 'on', 'MaskType', this.blkSearchExpr);
      % Check we found a block
      if (length(blk) == 1)
          % Get CCP configuration info from the block
          ccp_cro_id = get_param(blk, 'ccp_cro_id');
          ccp_cro_message_type = get_param(blk, 'ccp_cro_message_type');
          ccp_return_id = get_param(blk, 'ccp_return_id');
          ccp_return_message_type = get_param(blk, 'ccp_return_message_type');
          TOTAL_NUM_ODTS = get_param(blk, 'TOTAL_NUM_ODTS');

          this.CANIdCRO = eval(ccp_cro_id{:});
          this.CANIdDTO = eval(ccp_return_id{:});
          CROMessageType = ccp_cro_message_type{:};
          DTOMessageType = ccp_return_message_type{:};

          % Logic to set message type
          if strcmp(CROMessageType, DTOMessageType)
              switch CROMessageType
                  case 'Standard (11-bit identifier)'
                      this.messageType = VectorCAN.CAN_MESSAGE_STANDARD;
                  case 'Extended (29-bit identifier)'
                      this.messageType = VectorCAN.CAN_MESSAGE_EXTENDED;
              end
          else
              error('TargetsComms_ExternalModeCCPWithBlock:Constructor', 'Unable to set message type');
          end
          this.numODTs = str2num(TOTAL_NUM_ODTS{:});
          this.initialise();
      else
          error('TargetsComms_ExternalModeCCPWithBlock:Constructor', 'CCP block not found');
      end      
    end % function TargetsComms_ExternalModeCCPWithBlock

    function blkSearchExpr = get.blkSearchExpr(this)
      blkSearchExpr = this.getBlkSearchExpr();
    end
       
  end % methods
  
  methods(Access = 'protected')

    function blkSearchExpr = getBlkSearchExpr(this)
      error('TargetsComms_ExternalModeCCPWithBlock:getBlkSearchExpr', 'getBlkSearchExpr function should be overloaded in a subclass');
    end
        
  end % methods(Access = 'protected')
  
end % classdef