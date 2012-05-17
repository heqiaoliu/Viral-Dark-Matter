function fixptdialog(currentBlock)
%FIXPTDIALOG is for internal use only by Simulink

% Simulink Dynamic Dialog Management

% Copyright 1994-2009 The MathWorks, Inc.
%
% $Revision: 1.20.2.13 $ $Date: 2009/09/09 21:39:48 $

%
% get object parameters
%
G.block      = currentBlock;
G.Names      = get_param(G.block,'MaskNames');
G.Enables    = get_param(G.block,'MaskEnables');
G.Visibles   = get_param(G.block,'MaskVisibilities');
G.Values     = get_param(G.block,'MaskValues');
G.MaskStyles = get_param(G.block,'MaskStyles');

G.SetMaskValues = G.Values;
%
% the default is to leave all dialogs visible and enabled
%
for i=1:length(G.Enables)
    G.Enables{i} = 'on';
    G.Visibles{i} = 'on';
end

try
    
  G.maskType = get_param(G.block,'MaskType');
  
  G = commonToAllBlocks_pre(G);
    
  switch G.maskType
  
    case 'Data Type Propagation'
        
        G = handleDataTypePropagationBlock(G);
                
    case 'Sample Time Math'
       
       G = handleSampleTimeMathBlock(G);
       
    case 'Bitwise Operator'

       G = handleBitwiseBlock(G);
         
   otherwise
       
       %handleOtherBlocks;
  end
catch e %#ok
end    

set_param(G.block,'MaskEnables',G.Enables,'MaskVisibilities',G.Visibles);

if ~isequal(G.Values, G.SetMaskValues) 
    % update mask values when changes required from visible or enable calls
    set_param(G.block, 'MaskValues', G.SetMaskValues);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   commonToAllBlocks_pre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = commonToAllBlocks_pre(G_in)    
  %
  G = G_in;

  if any(strcmp(G.Names, 'OutDataTypeStr'))
      G = param_NOT_visible(G,'OutputDataTypeScalingMode');
      G = param_NOT_visible(G,'OutDataType');
      G = param_NOT_visible(G,'ConRadixGroup');
      G = param_NOT_visible(G,'OutScaling');
      
      G = param_NOT_visible(G,'GainDataTypeScalingMode');
      G = param_NOT_visible(G,'GainDataType');
      G = param_NOT_visible(G,'MatRadixGroup');
      G = param_NOT_visible(G,'GainScaling');
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   commonToAllBlocks_pre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   handleBitwiseBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = handleBitwiseBlock(G_in)
    %
    G = G_in;
    %
    [logicOpIsNOT,G] = get_param_value(G,'logicop','NOT');
    %
    if logicOpIsNOT
       %
       G = param_NOT_enabled(G,'NumInputPorts','1');
       %
       G = param_NOT_enabled(G,'UseBitMask','off');
       %
       G = param_NOT_visible(G,'BitMask');
       %
       G = param_NOT_visible(G,'BitMaskRealWorld');
    else        
       [UseBitMask,G] = get_param_value(G,'UseBitMask','on');
       %
       if UseBitMask
           %
           G = param_NOT_enabled(G,'NumInputPorts','1');
       else
           %
           G = param_NOT_visible(G,'BitMask');
           %
           G = param_NOT_visible(G,'BitMaskRealWorld');
       end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   handleBitwiseBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   handleDataTypePropagationBlock
%
% MaskVariables		  
%
%   PropDataTypeMode=@1;
%
%     PropDataType=@2;
%
%     IfRefDouble=@3;
%     IfRefSingle=@4;
%     IsSigned=@5;
%     NumBitsBase=@6;
%     NumBitsMult=@7;
%     NumBitsAdd=@8;
%     NumBitsAllowFinal=@9;
%
%   PropScalingMode=@10;
%
%     PropScaling=@11;
%
%     ValuesUsedBestPrec=@12;
%
%     SlopeBase=@13;
%     SlopeMult=@14;
%     SlopeAdd=@15;
%     BiasBase=@16;
%     BiasMult=@17;
%     BiasAdd=@18;"
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = handleDataTypePropagationBlock(G_in)
    %
    G = G_in;
    %
    % find inheritance settings
    %
    [specifyDataType,G] = get_param_value(G,'PropDataTypeMode','Specify via dialog');
    %
    DataTypeDeterminesScaling = 0;
    %
    if specifyDataType
        %
        G = param_NOT_visible(G,'IfRefDouble');
        G = param_NOT_visible(G,'IfRefSingle');
        G = param_NOT_visible(G,'IsSigned');
        G = param_NOT_visible(G,'NumBitsBase');
        G = param_NOT_visible(G,'NumBitsMult');
        G = param_NOT_visible(G,'NumBitsAdd');
        G = param_NOT_visible(G,'NumBitsAllowFinal');
        %
        [DataTypeDeterminesScaling,G] = get_datatype_determines_scaling(G,'PropDataType');
    else
        G = param_NOT_visible(G,'PropDataType');
    end
    %%   
    if DataTypeDeterminesScaling
      % 
      % All the scaling information is on a separate TAB.
      % It is undesirable for the TAB to be empty, so
      % PropScalingMode will be shown even if it is ignored.
      %   G = param_NOT_visible(G,'PropScalingMode');
      %
      G = param_NOT_visible(G,'PropScaling');
      G = param_NOT_visible(G,'ValuesUsedBestPrec');
      G = param_NOT_visible(G,'SlopeBase');
      G = param_NOT_visible(G,'SlopeMult');
      G = param_NOT_visible(G,'SlopeAdd');
      G = param_NOT_visible(G,'BiasBase');
      G = param_NOT_visible(G,'BiasMult');
      G = param_NOT_visible(G,'BiasAdd');
      %
    else
      [specifyPropScalingMode,G]  = get_param_value(G,'PropScalingMode','Specify via dialog');
      %
      [bestprecPropScalingMode,G] = get_param_value(G,'PropScalingMode','Obtain via best precision');
      %
      inheritPropScalingMode = ~( specifyPropScalingMode | bestprecPropScalingMode );
      %
      if inheritPropScalingMode
        %
        G = param_NOT_visible(G,'PropScaling');
        G = param_NOT_visible(G,'ValuesUsedBestPrec');
      else
        %
        G = param_NOT_visible(G,'SlopeBase');
        G = param_NOT_visible(G,'SlopeMult');
        G = param_NOT_visible(G,'SlopeAdd');
        G = param_NOT_visible(G,'BiasBase');
        G = param_NOT_visible(G,'BiasMult');
        G = param_NOT_visible(G,'BiasAdd');
        %    
        if specifyPropScalingMode
            %
            G = param_NOT_visible(G,'ValuesUsedBestPrec');
        else
            G = param_NOT_visible(G,'PropScaling');
        end
      end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   handleDataTypePropagationBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   handleSampleTimeMathBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = handleSampleTimeMathBlock(G_in)
     %
     G = G_in;
     %
     [mathop,G] = get_param_value(G,'TsampMathOp');
     %
     if strcmp(mathop,'*') || strcmp(mathop,'/')
        %
        [curValue,G] = get_param_value(G,'TsampMathImp','Offline Scaling Adjustment');
        
        if curValue
          %  
          G = param_NOT_enabled(G,'OutputDataTypeScalingMode','Inherit via internal rule');
          %
          G = param_NOT_visible(G,'DoSatur','off');
          %
          G = param_NOT_visible(G,'RndMeth','Floor');
        end
     else
       G = param_NOT_visible(G,'TsampMathImp','Online Calculations');
       %
       if strcmp(mathop,'Ts Only') || strcmp(mathop,'1/Ts Only')
          %
          G = param_NOT_visible(G,'DoSatur','off');
          %
          G = param_NOT_visible(G,'RndMeth','Floor');
       end
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   handleSampleTimeMathBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   param_NOT_visible
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = param_NOT_visible(G_in,paramName,paramValue)    
     %
     G = G_in;
     %
     i=find(strcmp(G.Names,paramName));
     if ~isempty(i)
         if nargin > 2
            G.SetMaskValues{i} = paramValue;
         end
         G.Visibles{i} = 'off';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   param_NOT_visible
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   param_NOT_enable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = param_NOT_enabled(G_in,paramName,paramValue)    
     %
     G = G_in;
     %
     i=find(strcmp(G.Names,paramName));
     if ~isempty(i)
         if nargin > 2
            G.SetMaskValues{i} = paramValue;
         end
         G.Enables{i} = 'off';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   param_NOT_enable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   get_param_value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [paramValue,G] = get_param_value(G_in,paramName,paramValueToMatch)    
     %
     G = G_in;
     %
     paramValue = [];
     %
     i=find(strcmp(G.Names,paramName));
     %
     if ~isempty(i)
         % 
         % Get parameter string from dialog
         % (NOTE: Parameter must be visible)
         %
         maskVisibles = get_param(G.block,'MaskVisibilities');
         if (strcmp(maskVisibles{i}, 'off')) 
            maskVisibles{i} = 'on';
            set_param(G.block,'MaskVisibilities',maskVisibles);
         end
         paramValue = get_param(G.block,paramName);       
     end
     %
     if nargin > 2
        %
        paramValue = isequal(paramValue,paramValueToMatch);
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   get_param_value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   get_datatype_determines_scaling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [DataTypeDeterminesScaling,G] = get_datatype_determines_scaling(G_in,paramName)    
     %
     G = G_in;
     %
     [strDataType,G] = get_param_value(G,paramName);
     DataTypeDeterminesScaling = slDDGUtil(G.block, 'dataTypeEditFieldDeterminesScaling', strDataType);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   get_datatype_determines_scaling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

