classdef CommonEnum
%CommonEnum Commonly used enumerations in signalblks package
  
%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $Date: 2010/03/26 17:50:33 $

  properties(Constant = true)
    PropertyOrInputPort = matlab.system.CompEnum({ ...
      'Property', ...
      'Input port'});

    AutoOrProperty = matlab.system.CompEnum({ ...
      'Auto', ...
      'Property'});
    
    FrameOrSampleBased = matlab.system.CompEnum({...
      'Frame based', ...
      'Sample based'});

    Dimension = matlab.system.CompEnum({...
        'All', 'Row','Column','Custom'} );
    
    RowVectorInterpretation = matlab.system.CompEnum({...
    'Multiple Channels','Single Channel'});
    
    ResetCondition = matlab.system.CompEnum({'Rising edge', ...
      'Falling edge', ...
      'Either edge', ...
      'Non-zero'});

    ROIForm = matlab.system.CompEnum( { ...
      'Rectangles', 'Lines', 'Label matrix', 'Binary mask'});

    ROIPortionToProcess = matlab.system.CompEnum ( { ...
      'Entire ROI', 'ROI perimeter' } );

    ROIStatistics = matlab.system.CompEnum( { ...
      'Individual statistics for each ROI',  ...
      'Single statistic for all ROIs'} );

    SineComputation = matlab.system.CompEnum( { ...
      'Trigonometric function',...
      'Table lookup'} );

    IgnoreWarnError = matlab.system.CompEnum({'Ignore', 'Warn', 'Error'});
    
    NonUnityFirstCoefficientAction = matlab.system.CompEnum( ...
      {'Replace with 1', 'Normalize'});
    
    DoubleSingleUsr = matlab.system.CompEnum({'double', 'single', ...
        matlab.system.getSpecifyString('either')});
    
    % fixed-point
    RoundingMethod = matlab.system.CompEnum(...
      {'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'});
    % Used in comms s-comps
    LimitedRoundMode =  matlab.system.CompEnum({'Floor', 'Nearest'});
    OverflowAction = matlab.system.CompEnum({'Wrap','Saturate'});

    % typical enum for prod mode
    FixptModeBasic = matlab.system.CompEnum({
      'Same as input', ...
      matlab.system.getSpecifyString('scaled')});
    % typical enum for prod mode with internal rule
    FixptModeInherit = matlab.system.CompEnum({
      'Internal rule', ...
      'Same as input', ...
      matlab.system.getSpecifyString('scaled')});
    % typical enum for accum mode
    FixptModeProd = matlab.system.CompEnum({
      'Same as product', ...
      'Same as input', ...
      matlab.system.getSpecifyString('scaled')});
    % typical enum for accum mode with internal rule
    FixptModeInheritProd = matlab.system.CompEnum({
      'Internal rule', ...
      'Same as product', ...
      'Same as input', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeInheritProdUnscaled = matlab.system.CompEnum({
      'Internal rule', ...
      'Same as product', ...
      matlab.system.getSpecifyString('unscaled')});
    % typical enum for output mode (where comp has no prod)
    FixptModeAccum = matlab.system.CompEnum({
      'Same as accumulator', ...
      'Same as input', ...
      matlab.system.getSpecifyString('scaled')});
    % typical enum for output mode
    FixptModeAccumProd = matlab.system.CompEnum({
      'Same as accumulator', ...
      'Same as product', ...
      'Same as input', ...
      matlab.system.getSpecifyString('scaled')});
    % typical enum for best-precision params
    FixptModeUnscaled = matlab.system.CompEnum({
      'Same word length as input', ...
      matlab.system.getSpecifyString('unscaled')});
    % typical enum for coefficients
    FixptModeEitherScale = matlab.system.CompEnum({
      'Same word length as input', ...
      matlab.system.getSpecifyString('either')});

    % 'FIRST INPUT' ENUMS
    FixptModeBasicFirst = matlab.system.CompEnum({
      'Same as first input', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeInheritUnscaled = matlab.system.CompEnum({
      'Internal rule', ...
      matlab.system.getSpecifyString('unscaled')});
    FixptModeInheritFirst = matlab.system.CompEnum({
      'Internal rule', ...
      'Same as first input', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeInheritProdFirst = matlab.system.CompEnum({
      'Internal rule', ...
      'Same as product', ...
      'Same as first input', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeProdFirst = matlab.system.CompEnum({...
      'Same as product', ...
      'Same as first input', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeAccumProdFirst = matlab.system.CompEnum({
      'Same as accumulator', ...
      'Same as product', ...
      'Same as first input', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeAccumFirst = matlab.system.CompEnum({...
      'Same as accumulator', ...
      'Same as first input', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeAccumNoInput = matlab.system.CompEnum({...
      'Same as accumulator', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeProdNoInput = matlab.system.CompEnum({
      'Same as product', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeAccumProdNoInput = matlab.system.CompEnum({
      'Same as accumulator', ...
      'Same as product', ...
      matlab.system.getSpecifyString('scaled')});
    FixptModeEitherScaleFirst = matlab.system.CompEnum({
      'Same word length as first input', ...
      matlab.system.getSpecifyString('either')});
    % enum for Specify scaled numeric type only
    FixptModeScaledOnly = matlab.system.CompEnum({...
      matlab.system.getSpecifyString('scaled')});
    % enum for Specify unscaled numeric type only
    FixptModeUnscaledOnly = matlab.system.CompEnum({...
      matlab.system.getSpecifyString('unscaled')});


  end
  methods(Static = true)
    function en = getEnum(name)
      persistent instance;
      if isempty(instance)
        instance = signalblks.CommonEnum;
      end

      switch name
        case 'ResetCondition'
          en = instance.ResetCondition;
        case 'PropertyOrInputPort'
          en = instance.PropertyOrInputPort;
        case 'AutoOrProperty'
          en = instance.AutoOrProperty;
        case 'FrameOrSampleBased'
          en = instance.FrameOrSampleBased;
        case 'Dimension'
          en = instance.Dimension;
        case 'RowVectorInterpretation'
          en = instance.RowVectorInterpretation;          
        case 'IgnoreWarnError'
          en = instance.IgnoreWarnError;
        case 'NonUnityFirstCoefficientAction'
          en = instance.NonUnityFirstCoefficientAction;
        case 'RoundingMethod'
          en = instance.RoundingMethod;
        case 'LimitedRoundMode'
          en = instance.LimitedRoundMode;
        case 'OverflowAction'
          en = instance.OverflowAction;
        case 'ROIForm'
          en = instance.ROIForm;
        case 'ROIPortionToProcess'
          en = instance.ROIPortionToProcess;
        case 'ROIStatistics'
          en = instance.ROIStatistics;
        case 'SineComputation'
          en = instance.SineComputation;
        case 'DoubleSingleUsr'
          en = instance.DoubleSingleUsr;          
        case 'FixptModeBasic'
          en = instance.FixptModeBasic;
        case 'FixptModeProd'
          en = instance.FixptModeProd;
        case 'FixptModeAccum'
          en = instance.FixptModeAccum;
        case 'FixptModeAccumProd'
          en = instance.FixptModeAccumProd;
        case 'FixptModeInherit'
          en = instance.FixptModeInherit;
        case 'FixptModeInheritUnscaled'
          en = instance.FixptModeInheritUnscaled;
        case 'FixptModeInheritProd'
          en = instance.FixptModeInheritProd;
        case 'FixptModeInheritProdUnscaled'
          en = instance.FixptModeInheritProdUnscaled;
        case 'FixptModeUnscaled'
          en = instance.FixptModeUnscaled;
        case 'FixptModeEitherScale'
          en = instance.FixptModeEitherScale;
        case 'FixptModeAccumNoInput'
          en = instance.FixptModeAccumNoInput;
        case 'FixptModeProdNoInput'
          en = instance.FixptModeProdNoInput;
        case 'FixptModeAccumProdNoInput'
          en = instance.FixptModeAccumProdNoInput;
        case 'FixptModeEitherScaleFirst'
          en = instance.FixptModeEitherScaleFirst;
        case 'FixptModeScaledOnly'
          en = instance.FixptModeScaledOnly;
        case 'FixptModeUnscaledOnly'
          en = instance.FixptModeUnscaledOnly;
        case 'FixptModeBasicFirst'
          en = instance.FixptModeBasicFirst;
        case 'FixptModeInheritFirst'
          en = instance.FixptModeInheritFirst;
        case 'FixptModeInheritProdFirst'
          en = instance.FixptModeInheritProdFirst;
        case 'FixptModeProdFirst'
          en = instance.FixptModeProdFirst;
        case 'FixptModeAccumProdFirst'
          en = instance.FixptModeAccumProdFirst;
        case 'FixptModeAccumFirst'
          en = instance.FixptModeAccumFirst;
        otherwise
          error('spblks:system:CommonEnum:unknownEnum', ...
            'The enum %s is unknown.', name);
      end
    end

  end
end
