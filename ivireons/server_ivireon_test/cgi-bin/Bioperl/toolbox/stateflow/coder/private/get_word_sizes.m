function [algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo,rtwSettingsInfo] = get_word_sizes(relevantMachineName,targetName)
  
    codingSFunction = strcmp(targetName,'sfun');
    codingRTW = strcmp(targetName,'rtw');

    algWordLengthStr = get_param(relevantMachineName,'ProdHWWordLengths');

    
    % The targetHwInfo describes the target for which code is currently
    % being generated for.  When simulation through code generation is
    % occurring the current code generation target is the Matlab Host
    % computer. 
    %    The following DEFAULT targetHwInfo properties are valid for all
    % the current Matlab Hosts.
    %    If the code is being generated for RTW usage, these defaults
    % will be overridden by the values from the models Hardware 
    % Implementation pane
    %
    targetHwInfo.hwDeviceType = false; % microprocessor
    targetHwInfo.signedDivRounding = 0;  % unknown
    targetHwInfo.divByZeroProtectionNotWanted = false;
    targetHwInfo.signedShiftIsArithmetic = true;
    
    if strcmp(lower(get_param(relevantMachineName,'BlockDiagramType')),'library')

      algorithmHwInfo.hwDeviceType = false;
      algorithmHwInfo.signedDivRounding = 0;
      algorithmHwInfo.divByZeroProtectionNotWanted = false;
      algorithmHwInfo.signedShiftIsArithmetic = true;

      rtwSettingsInfo.castFloat2IntPortableWrapping = true;
      rtwSettingsInfo.mapNaN2IntZero                = true;
      rtwSettingsInfo.genFunctionFixptDiv           = true;
      rtwSettingsInfo.genFunctionFixptMul           = true;
      rtwSettingsInfo.genFunctionFixptMisc          = true;
      rtwSettingsInfo.supportNonFinites             = true;
      rtwSettingsInfo.correctNetSlopeViaDiv         = false;      

    else
      configSet = getActiveConfigSet(relevantMachineName);
      
      try
          divByZeroProtectionNotWanted = strcmp('on',get_param(configSet,'NoFixptDivByZeroProtection'));
      catch
          divByZeroProtectionNotWanted = false;
      end
          
      % algorithm target aka final production deployment target
      %
      % Currently 0 means Microprocessor and 
      %          1 means ASIC/FPGA/Unconstrained Integer Sizes
      devType = get_param(configSet,'ProdHWDeviceType');
      algorithmHwInfo.hwDeviceType = strncmp(devType,'ASIC',4);

      divRndStr = get_param(configSet,'ProdIntDivRoundTo');
      if strcmp(upper(divRndStr),'ZERO')
        algorithmHwInfo.signedDivRounding = 1;
      elseif strcmp(upper(divRndStr),'FLOOR')
        algorithmHwInfo.signedDivRounding = 2;
      else
        algorithmHwInfo.signedDivRounding = 0;  % unknown
      end

      algorithmHwInfo.divByZeroProtectionNotWanted = divByZeroProtectionNotWanted;

      try
        algorithmHwInfo.signedShiftIsArithmetic = strcmp('on',get_param(configSet,'ProdShiftRightIntArith'));
      catch
        algorithmHwInfo.signedShiftIsArithmetic = true;
      end 

      % target HW aka current code generation target
      %
      hardware = configSet.getComponent('Hardware Implementation');
      if codingRTW && strcmp(hardware.TargetUnknown, 'off')
          
          devType = get_param(configSet,'TargetHWDeviceType');
          targetHwInfo.hwDeviceType = strncmp(devType,'ASIC',4);
          
          divRndStr = get_param(configSet,'TargetIntDivRoundTo');
          if strcmp(upper(divRndStr),'ZERO')
              targetHwInfo.signedDivRounding = 1;
          elseif strcmp(upper(divRndStr),'FLOOR')
              targetHwInfo.signedDivRounding = 2;
          else
              targetHwInfo.signedDivRounding = 0;  % unknown
          end

          targetHwInfo.divByZeroProtectionNotWanted = divByZeroProtectionNotWanted;

          try       
              % An error can occur here legacy models
              % Configuration parameter 'TargetShiftRightIntArith' is not available since the current 
              % execution target hardware has not been configured.  To specify the target hardware 
              % characteristics, go to the Hardware Implementation page of the Configuration Parameters 
              % dialog.
              % 
              targetHwInfo.signedShiftIsArithmetic = strcmp('on',get_param(configSet,'TargetShiftRightIntArith'));
          catch
              targetHwInfo.signedShiftIsArithmetic = true;
          end 
      end 

      castFloat2IntPortableWrapping = true;
      switch get_param(configSet,'EfficientFloat2IntCast')
          case 'on',
          case 'off'
              castFloat2IntPortableWrapping = true;
          otherwise,
              warn('Parameter ''EfficientFloat2IntCast'' had an unexpected value. Defaulting to off.');
      end

      mapNaN2IntZero = true;
      switch get_param(configSet,'EfficientMapNaN2IntZero')
          case 'on',
          case 'off'
              mapNaN2IntZero = true;
          otherwise,
              warn('Parameter ''EfficientMapNaN2IntZero'' had an unexpected value. Defaulting to off.');
      end

      %
      % hardcode the following values for now, 
      % a likely interim solution is get these via rtw_host_implementation_props
      % the final proper solution will be to put these on the config params dialog
      %
      rtwSettingsInfo.genFunctionFixptDiv           = true; % hardcode
      rtwSettingsInfo.genFunctionFixptMul           = true; % hardcode
      rtwSettingsInfo.genFunctionFixptMisc          = true; % hardcode

      if(codingSFunction)
          % G292084: for simulation, treat these properties as true
          % so that we dont flip-flp unnecessarily regenerating code.
          rtwSettingsInfo.castFloat2IntPortableWrapping = true;
          rtwSettingsInfo.mapNaN2IntZero                = true;
          rtwSettingsInfo.supportNonFinites             = true;
      else
          rtwSettingsInfo.castFloat2IntPortableWrapping = castFloat2IntPortableWrapping;
          rtwSettingsInfo.mapNaN2IntZero                = mapNaN2IntZero;
          rtwSettingsInfo.supportNonFinites             = strcmp('on',get_param(configSet,'SupportNonFinite'));
      end
      rtwSettingsInfo.correctNetSlopeViaDiv         = strcmp('on',get_param(configSet,'UseIntDivNetSlope'));

    end

    % If we're building for a Simulink Simulation target (normal simulation,
    % accelerator, rapid accelerator, or model reference), then we need to
    % ignore enforceIntegerDowncasts or we will get undesirable re-builds
    % or changing answers. See gecks g421967, g421969 and g426640 
    % for more information.
    targetIntendedForSimulation = false;
    if(codingSFunction)
        targetIntendedForSimulation = true;
    elseif(codingRTW)
        if(strcmpi(get_param(relevantMachineName,'ModelReferenceTargetType'),'SIM'))
            targetIntendedForSimulation = true;
        end
        if(strcmpi(get_param(relevantMachineName,'SystemTargetFile'),'raccel.tlc'))
            targetIntendedForSimulation = true;
        end                   
    end        
    if(targetIntendedForSimulation)
        targetHwInfo.divByZeroProtectionNotWanted = false;
        algorithmHwInfo.divByZeroProtectionNotWanted = false;
    end

    [s,e] = regexp(algWordLengthStr,'\d+');
    if(length(s)<4)
        error('why');
    end
    for i=1:4
        nBitsStr = algWordLengthStr(s(i):e(i));
        nBits = sscanf(nBitsStr,'%d');
        if(isempty(nBits))
            error('why');
        end
        algorithmWordsizes(i) = nBits;
    end
    if(codingSFunction)
        % Note sue what the right routine one should use is...
        hi = hostcpuinfo();
        targetWordsizes = hi(4:7);
    elseif(codingRTW)
        targetWordsizesStruct = rtwwordlengths(relevantMachineName);
        targetWordsizes(1) = double(targetWordsizesStruct.CharNumBits);
        targetWordsizes(2) = double(targetWordsizesStruct.ShortNumBits);
        targetWordsizes(3) = double(targetWordsizesStruct.IntNumBits);
        targetWordsizes(4) = double(targetWordsizesStruct.LongNumBits);
    else
        targetWordsizes = coder_options('targetWordsizes');
    end

    % Sort them to be on the safe side
    algorithmWordsizes = sort(algorithmWordsizes);
    targetWordsizes = sort(targetWordsizes);

 
