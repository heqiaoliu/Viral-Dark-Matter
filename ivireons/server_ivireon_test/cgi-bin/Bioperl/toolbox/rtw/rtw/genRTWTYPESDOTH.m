function [ansiDataTypeName] = genRTWTYPESDOTH(hardwareImp, hardwareDeploy, configInfo, simulinkInfo)
%GENRTWTYPESDOTH Create rtwtypes.h based on hardware characteristics and
%additional configuration information. Returns appropriate data types names
%for the standard MATLAB types.
%
% NOTE: This function does not require a model to be opened.
%
% ARGUMENTS:
%
% hardwareImp
%     CharNumBits                   = int32(8);
%     ShortNumBits                  = int32(16);
%     IntNumBits                    = int32(32);
%     LongNumBits                   = int32(32);
%     WordSize                      = int32(32);
%     ShiftRightIntArith            = true;  
%     IntDivRoundTo                 = 'Floor'; % 'Floor', 'Zero' or 'Undefined'
%     Endianess                     = 'LittleEndian'; % 'LittleEndian', 'BigEndian' or 'Unspecified'
%     HWDeviceType                  = 'Generic->32-bit Embedded Processor';
%     TypeEmulationWarnSuppressLevel= 0      (optional)
%     PreprocMaxBitsSint            = 32;    (optional)
%     PreprocMaxBitsUint            = 32;    (optional)
%    
% hardwareDeploy
%     CharNumBits                   = int32(8);
%     ShortNumBits                  = int32(16);
%     IntNumBits                    = int32(32);
%     LongNumBits                   = int32(32);
%
% configInfo
%     GenDirectory                  = '/temp/slprj/ert/_sharedutils/'
%     PurelyIntegerCode             = false;
%     SupportComplex                = true;
%     MaxMultiwordBits              = 2048;
%
% simulinkInfo                      (optional, set to [] if unused)
%     Style                         = 'minimized'; % 'full' or 'minimized'
%     SharedLocation                = false;
%     IsERT                         = true;
%     PortableWordSizes             = false;
%     SupportNonInlinedSFcns        = false;
%     GRTInterface                  = false;
%     ReplacementTypesOn            = false;
%     ReplacementTypesStruct        = [];
%     GenChunkDefs                  = false;
%     GenBuiltInDTEnums             = false;
%     MatFileLogging                = false;

%   Copyright 2003-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.38 $
%   $Date: 2010/05/20 02:51:56 $

    if isempty(simulinkInfo)
        %Setup defaults
        usingSimulink = false;
        simulinkInfo.Style = 'minimized';
        simulinkInfo.SharedLocation = false;
        simulinkInfo.IsERT = true;
        simulinkInfo.PortableWordSizes = false;
        simulinkInfo.SupportNonInlinedSFcns = false;
        simulinkInfo.GRTInterface = false;
        simulinkInfo.ReplacementTypesOn = false;
        simulinkInfo.ReplacementTypesStruct = [];
        simulinkInfo.GenChunkDefs = false;
        simulinkInfo.GenBuiltInDTEnums = false;
        simulinkInfo.MatFileLogging = false;
        simulinkInfo.GenTimingBridge = false;
    else
        usingSimulink = true;
    end
    locCheckArgs(hardwareImp, hardwareDeploy, configInfo, simulinkInfo)
    
    % Create the Ansi datatype table
    [ansiDataTypeTable, ansiDataTypeName] = rtwprivate('initAnsiDataType', ...
                                                      hardwareDeploy, hardwareImp, ...
                                                      configInfo.PurelyIntegerCode, ...
                                                      simulinkInfo.ReplacementTypesOn, ...
                                                      simulinkInfo.ReplacementTypesStruct);

    % Include COMPLEX number typedefs if select 
    if configInfo.SupportComplex
        SUPPORT_COMPLEX = 1;
    else
        SUPPORT_COMPLEX = 0;
    end  
    style = simulinkInfo.Style;
    MaxMultiwordBits = configInfo.MaxMultiwordBits;
    
    % skip update rtwtypes.h operation if it already exists (incremental code gen)
    tmwtypesFile = fullfile(configInfo.GenDirectory,'rtwtypes.h');
    rtwtypesChecksumFile = fullfile(configInfo.GenDirectory,'rtwtypeschksum.mat');
    ansiDataTypeName.overwritten = false;
    if exist(tmwtypesFile,'file') && simulinkInfo.SharedLocation  
        savedrtwtypeshchksum = load(rtwtypesChecksumFile);
        overwriteMaxMultiwordBits = false;
        overwriteStyle = false;
        overwriteSupportComplex = false;
        overwriteGenChunkDefs = false;
        overwriteGenBuiltInDTEnums = false;
        
        % When previously generated multiword max length is less than currently
        % needed multiword max length, rtwtypes.h needs to be overwritten.
        if savedrtwtypeshchksum.configInfo.MaxMultiwordBits < configInfo.MaxMultiwordBits
            overwriteMaxMultiwordBits = true;
        end
        
        % When previously generated style is minimized but current style is full,
        % rtwtypes.h needs to be overwritten. Reasons for this can be: GRTInterface
        % is on or NumChildSfcn > 0.
        if strcmpi(simulinkInfo.Style,'full') && ...
                ~strcmpi(simulinkInfo.Style, savedrtwtypeshchksum.simulinkInfo.Style)
            overwriteStyle = true;
        end
        
        % When previously generated does not support complex but current needs,
        % rtwtypes.h needs be overwritten.
        if ~savedrtwtypeshchksum.configInfo.SupportComplex && SUPPORT_COMPLEX
            overwriteSupportComplex = true;
        end
        
        % When previously generated does not support GenChunkDefs but current needs,
        % rtwtypes.h needs be overwritten.
        if ~savedrtwtypeshchksum.simulinkInfo.GenChunkDefs && simulinkInfo.GenChunkDefs 
            overwriteGenChunkDefs = true;  
        end
        
        % When previously generated does not support GenBuiltInDTEnums but current needs,
        % rtwtypes.h needs be overwritten.
        if ~savedrtwtypeshchksum.simulinkInfo.GenBuiltInDTEnums && simulinkInfo.GenBuiltInDTEnums 
            overwriteGenBuiltInDTEnums = true;  
        end
        
        if ~overwriteMaxMultiwordBits && ~overwriteStyle && ~overwriteSupportComplex ...
                && ~overwriteGenChunkDefs && ~overwriteGenBuiltInDTEnums
            % No need to overwrite rtwtypes.h
            return;
        end
        
        ansiDataTypeName.overwritten = true;
        
        if ~overwriteMaxMultiwordBits
            MaxMultiwordBits = savedrtwtypeshchksum.configInfo.MaxMultiwordBits;
        end
        if ~overwriteStyle
            style = savedrtwtypeshchksum.simulinkInfo.Style;
        end
        if ~overwriteSupportComplex
            SUPPORT_COMPLEX = savedrtwtypeshchksum.configInfo.SupportComplex;
        end
    end

    try
        f = -1;
        save(rtwtypesChecksumFile, 'hardwareImp', 'hardwareDeploy', 'configInfo', 'simulinkInfo');
        
        % the Ansi datatype checksum is needed in both the full version and the
        % optimized version
        ansi_data_type_size_checksum = rtwprivate('getAnsiDataType',ansiDataTypeTable,'RtwTypesID');

        % get the ansi data types, and some other related info such as native word
        % size and floatingpoint support.
        ansi_int8          = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT8');
        if isempty(ansi_int8.val)
            DAStudio.error('RTW:buildProcess:missingRequiredDataType',...
                           '"int8"', '8-bits, 16-bits or 32-bits');
        end
        ansi_uint8         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT8');
        if isempty(ansi_uint8.val)
            DAStudio.error('RTW:buildProcess:missingRequiredDataType',...
                           '"uint8"', '8-bits, 16-bits or 32-bits');
        end

        ansi_int16         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT16');
        if isempty(ansi_int16.val)
            DAStudio.error('RTW:buildProcess:missingRequiredDataType',...
                           '"int16"', '16-bits or 32-bits');
        end
        ansi_uint16        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT16');
        if isempty(ansi_uint16.val)
            DAStudio.error('RTW:buildProcess:missingRequiredDataType',...
                           '"uint16"', '16-bits or 32-bits');
        end

        ansi_int32         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT32');
        if isempty(ansi_int32.val)
            DAStudio.error('RTW:buildProcess:missingRequired32DataType', '"int32"');
        end
        ansi_uint32        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT32');
        if isempty(ansi_uint32.val)
            DAStudio.error('RTW:buildProcess:missingRequired32DataType', '"uint32"');
        end

        ansi_int64         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT64');
        ansi_uint64        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT64');

        ansi_real64        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_DOUBLE');
        ansi_real32        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_SINGLE');

        ansi_boolean       = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_BOOLEAN');

        ansi_support_fp    = rtwprivate('getAnsiDataType',ansiDataTypeTable,'SupportFloatingPoint');

        ideal_ansi_sizes   = all([ansi_int8.native_support...
                            ansi_int16.native_support...
                            ansi_int32.native_support]);

        % if non-ERT code format, simply include tmwtypes.h and simstruc_types.h
        if strcmpi(style,'full')
            f=fopen(tmwtypesFile, 'wt');
            fprintf(f, '%s\n', '');
            fprintf(f, '%s\n', '#ifndef __RTWTYPES_H__  ');
            fprintf(f, '%s\n', '  #define __RTWTYPES_H__  ');
            fprintf(f, '%s\n', '  #include "tmwtypes.h"  ');
            % define the rtwtypes ID so that an ioncorrect rtwtypes.h inclusion can be
            % detected
            fprintf(f, '%s\n', '  ');
            fprintf(f, '%s\n', '/* This ID is used to detect inclusion of an incompatible rtwtypes.h */');
            fprintf(f, '%s\n', ['#define ' ansi_data_type_size_checksum.val ]);
            fprintf(f, '%s\n', '  ');
            fprintf(f, '%s\n', '  #include "simstruc_types.h"  ');
            fprintf(f, '%s\n', '    #ifndef POINTER_T  ');
            fprintf(f, '%s\n', '    # define POINTER_T  ');
            fprintf(f, '%s\n', '      typedef void * pointer_T;  ');
            fprintf(f, '%s\n', '    #endif  ');
            fprintf(f, '%s\n', '    #ifndef TRUE  ');
            fprintf(f, '%s\n', '    # define TRUE (1U)  ');
            fprintf(f, '%s\n', '    #endif  ');
            fprintf(f, '%s\n', '    #ifndef FALSE  ');
            fprintf(f, '%s\n', '    # define FALSE (0U)  ');
            fprintf(f, '%s\n', '    #endif  ');    
            
            fprintf(f, '%s\n', '    #ifndef MAT_FILE  ');
            if simulinkInfo.MatFileLogging
                fprintf(f, '%s\n', '    # define MAT_FILE 1  ');
            else
                fprintf(f, '%s\n', '    # define MAT_FILE 0  ');
            end
            fprintf(f, '%s\n', '    #endif  ');
            
            if simulinkInfo.ReplacementTypesOn
                ReplaceTypesHdrList = {};
                ReplaceTypeDefs = '';
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.double, 'real_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.single, 'real32_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.int32, 'int32_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.int16, 'int16_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.int8, 'int8_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.uint32, 'uint32_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.uint16, 'uint16_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.uint8, 'uint8_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.boolean, 'boolean_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.int, 'int_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.uint, 'uint_T', SUPPORT_COMPLEX);
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.char, 'char_T', SUPPORT_COMPLEX);        
                if ~(isempty(ReplaceTypesHdrList) && isempty(ReplaceTypeDefs))
                    fprintf(f, '%s\n', '  ');
                    fprintf(f, '%s\n', '/* Define RTW replacement data types. */  ');
                end
                for i=1:length(ReplaceTypesHdrList)
                    DataTypeList='';            
                    for j=1:length(ReplaceTypesHdrList{i}.DataTypes)
                        DataTypeList = [DataTypeList ReplaceTypesHdrList{i}.DataTypes{j} ' ']; %#ok
                    end
                    %check delimiters
                    rheader = ReplaceTypesHdrList{i}.HeaderFile;
                    if (rheader(1)=='"' && rheader(end)=='"') ||...
                            (rheader(1)=='<' && rheader(end)=='>')
                        fprintf(f, '%s\n', ['  #include ' ReplaceTypesHdrList{i}.HeaderFile ' /* User defined replacement datatype for ' DataTypeList ' */ ']);
                    else
                        fprintf(f, '%s\n', ['  #include "' ReplaceTypesHdrList{i}.HeaderFile '" /* User defined replacement datatype for ' DataTypeList ' */ ']);
                    end
                end
                fprintf(f, '%s\n', ReplaceTypeDefs);
                fprintf(f, '%s\n', '  ');
            end
            
            % emit additional typedef's
            dumpAdditionalTypeDefs(f, ansiDataTypeTable, true, [], false, []);
            % emit additional complex types
            dumpAdditionalComplexTypes(f, ansiDataTypeTable, SUPPORT_COMPLEX, true, true);
            % Conditionally emit MultiWord type definitions
            dumpMultiWordTypeDefs(f, ...
                                  simulinkInfo.GenChunkDefs, ...
                                  ansiDataTypeTable, ...
                                  'chunks', ...
                                  SUPPORT_COMPLEX, ...
                                  MaxMultiwordBits, ...
                                  [], false, []);

            fprintf(f, '%s\n', '#endif /* __RTWTYPES_H__ */  ');
            
            fclose(f);
            return
        end % if strcmpi(style,'full')

        % collect included header for RTW replacement data types.
        ReplaceTypesHdrList = {};
        ReplaceTypeDefs = '';        
        
        % create the file in specified directory.
        f=fopen(tmwtypesFile, 'wt');

        % following lines begin creation of original tmwtypes.h
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '#ifndef __RTWTYPES_H__  ');
        fprintf(f, '%s\n', '#define __RTWTYPES_H__  ');
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '#ifndef TRUE  ');
        fprintf(f, '%s\n', '# define TRUE (1U)  ');
        fprintf(f, '%s\n', '#endif  ');
        fprintf(f, '%s\n', '#ifndef FALSE  ');
        fprintf(f, '%s\n', '# define FALSE (0U)  ');
        fprintf(f, '%s\n', '#endif  ');
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '#ifndef __TMWTYPES__  ');
        
        ansi_char  = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_CHAR');
        ansi_short = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_SHORT');
        ansi_int   = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT');
        ansi_long  = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_LONG');
        if hardwareImp.ShiftRightIntArith
            shiftRight = 'on';
        else
            shiftRight = 'off';
        end

        if simulinkInfo.PortableWordSizes
            ENABLE_PORTABLE_WORDSIZES = 1;
        else
            ENABLE_PORTABLE_WORDSIZES = 0;
        end  

        fprintf(f, '%s\n', '#define __TMWTYPES__  ');
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '#include <limits.h>  ');
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/*=======================================================================*  ');
        fprintf(f, '%s\n', ' * Target hardware information                                           ');
        fprintf(f, '%s\n',[' *   Device type: ' hardwareImp.HWDeviceType]);
        fprintf(f, '%s%3d%s%3d%s%3d\n', ' *   Number of bits:     char: ', ansi_char.numBits, ...
            '    short:  ', ansi_short.numBits, '    int: ', ansi_int.numBits);
        fprintf(f, '%s%3d%s%3d\n',' *                       long: ', ansi_long.numBits, ...
            '      native word size: ', rtwprivate('getAnsiDataType',ansiDataTypeTable,'NativeWordSize'));
        fprintf(f, '%s\n',[' *   Byte ordering: ', hardwareImp.Endianess]);
        fprintf(f, '%s\n',[' *   Signed integer division rounds to: ', hardwareImp.IntDivRoundTo]);
        fprintf(f, '%s\n',[' *   Shift right on a signed integer as arithmetic shift: ', shiftRight]);
        fprintf(f, '%s\n', ' *=======================================================================*/  ');
        fprintf(f, '%s\n', '  ');
        hostWordLengths = [];
        if (ENABLE_PORTABLE_WORDSIZES == 1)
            %Get host word lengths to try to map to target sizes
            hostWordLengths = rtwhostwordlengths();
            hostWordLengths.CharNumBits  = int32(hostWordLengths.CharNumBits);
            hostWordLengths.ShortNumBits = int32(hostWordLengths.ShortNumBits);
            hostWordLengths.IntNumBits   = int32(hostWordLengths.IntNumBits);
            hostWordLengths.LongNumBits  = int32(hostWordLengths.LongNumBits);
            hostWordLengths.WordSize     = hostWordLengths.LongNumBits;
            
            if ((hostWordLengths.LongNumBits ~= hardwareDeploy.LongNumBits) && ...
                (hostWordLengths.IntNumBits ~= hardwareDeploy.LongNumBits)) || ...
               ((hostWordLengths.LongNumBits ~= hardwareDeploy.IntNumBits) && ...
                (hostWordLengths.IntNumBits ~= hardwareDeploy.IntNumBits) && ...
                (hostWordLengths.ShortNumBits ~= hardwareDeploy.IntNumBits) && ...
                (hostWordLengths.CharNumBits ~= hardwareDeploy.IntNumBits))
                DAStudio.error('RTW:buildProcess:missingTargetIntOrLongDataTypeForPortableWordSizes');
            end
            fprintf(f, '%s\n', '   ');
            fprintf(f, '%s\n', '#ifdef PORTABLE_WORDSIZES   /* PORTABLE_WORDSIZES defined */');
            fprintf(f, '%s\n', '  ');
            fprintf(f, '%s\n', '/*=======================================================================*  ');
            fprintf(f, '%s\n', ' * Host information                                           ');
            fprintf(f, '%s%3d%s%3d%s%3d\n', ' *   Number of bits:     char: ', hostWordLengths.CharNumBits, ...
                '    short:  ', hostWordLengths.ShortNumBits, '    int: ', hostWordLengths.IntNumBits);
            fprintf(f, '%s%3d%s%3d\n',' *                       long: ', hostWordLengths.LongNumBits, ...
                '      native word size: ', hostWordLengths.WordSize);
            fprintf(f, '%s\n', ' *=======================================================================*/  ');
            fprintf(f, '%s\n', '  ');
            fprintf(f, '%s\n', '/*=======================================================================*  ');
            fprintf(f, '%s\n', ' * Fixed width word size data types:                                     *  ');
            fprintf(f, '%s\n', ' *   int8_T, int16_T, int32_T     - signed 8, 16, or 32 bit integers     *  ');
            fprintf(f, '%s\n', ' *   uint8_T, uint16_T, uint32_T  - unsigned 8, 16, or 32 bit integers   *  ');
            if ~configInfo.PurelyIntegerCode
                fprintf(f, '%s\n', ' *   real32_T, real64_T           - 32 and 64 bit floating point numbers *  ');
            end
            if ~ideal_ansi_sizes
                fprintf(f, '%s\n', ' *                                                                       *  ');
                fprintf(f, '%s\n', ' *                                                                       *  ');
                fprintf(f, '%s\n', ' *   Note:  Because the specified hardware does not have native support  *  ');
                fprintf(f, '%s\n', ' *          for all data sizes, some data types are actually typedef''ed  *  ');
                fprintf(f, '%s\n', ' *          from larger native data sizes.  The following data types are *  ');
                fprintf(f, '%s\n', ' *          not in the ideal native data types:                          *  ');
                fprintf(f, '%s\n', ' *                                                                       *  ');
                if ~ansi_int8.native_support
                    fprintf(f, '%s\n', ' *          int8_T, uint8_T                                              *  ');
                end
                if ~ansi_int16.native_support
                    fprintf(f, '%s\n', ' *          int16_T, uint16_T                                            *  ');
                end
                if ~ansi_int32.native_support
                    fprintf(f, '%s\n', ' *          int32_T, uint32_T                                            *  ');
                end
            end
            fprintf(f, '%s\n', ' *=======================================================================*/  ');
            fprintf(f, '%s\n', '  ');
            
            schar_name = []; %#ok<NASGU>
            uchar_name = []; %#ok<NASGU>
            [uchar_name, schar_name] = locMapToHost(hostWordLengths, hardwareDeploy, 8);
            fprintf(f, '%s\n', ['typedef ' schar_name  ' int8_T;']);
            fprintf(f, '%s\n', ['typedef ' uchar_name  ' uint8_T;']);
            
            [uName, sName] = locMapToHost(hostWordLengths, hardwareDeploy, 16);
            fprintf(f, '%s\n', ['typedef ' sName  ' int16_T;']);
            fprintf(f, '%s\n', ['typedef ' uName  ' uint16_T;']);
            
            sint_name = []; %#ok<NASGU>
            uint_name = []; %#ok<NASGU>
            [uint_name, sint_name] = locMapToHost(hostWordLengths, hardwareDeploy, 32);
            fprintf(f, '%s\n', ['typedef ' sint_name  ' int32_T;']);
            fprintf(f, '%s\n', ['typedef ' uint_name  ' uint32_T;']);
            
            if ~configInfo.PurelyIntegerCode
                if ~isempty(ansi_real32.val)
                    fprintf(f, '%s\n', ['typedef ' ansi_real32.val ' real32_T;']);
                end
                if ~isempty(ansi_real64.val)
                    fprintf(f, '%s\n', ['typedef ' ansi_real64.val ' real64_T;']);
                end
            end
            
            fprintf(f, '%s\n', '  ');
            fprintf(f, '%s\n', '/*===========================================================================*  ');
            if isempty(ansi_real64.val)
                fprintf(f, '%s\n', ' * Generic type definitions: boolean_T, int_T, uint_T, ulong_T, char_T,      *  ');
                fprintf(f, '%s\n', ' *                           and byte_T.                                     *  ');
            else
                fprintf(f, '%s\n', ' * Generic type definitions: real_T, time_T, boolean_T, int_T, uint_T,       *  ');
                fprintf(f, '%s\n', ' *                           ulong_T, char_T and byte_T.                     *  ');
            end
            
            fprintf(f, '%s\n', ' *===========================================================================*/  ');
            fprintf(f, '%s\n', '  ');
            
            
            if ~configInfo.PurelyIntegerCode
                if ~isempty(ansi_real64.val)
                    fprintf(f, '%s\n', ['typedef ' ansi_real64.val ' real_T;']);
                    fprintf(f, '%s\n', ['typedef ' ansi_real64.val ' time_T;']);
                elseif ~isempty(ansi_real32.val)
                    fprintf(f, '%s\n', ['typedef ' ansi_real32.val ' real_T;']);
                    fprintf(f, '%s\n', ['typedef ' ansi_real32.val ' time_T;']);
                end
            end
            
            % This is checking if Data Type Replacement has been used
            % to redefine boolean. uint8 is the default.
            boolean_is_int8 = 0;
            boolean_is_uint16 = 0; 
            boolean_is_int16 = 0;
            boolean_is_uint32 = 0; 
            boolean_is_int32 = 0;
            if simulinkInfo.ReplacementTypesOn
                if ~isempty(simulinkInfo.ReplacementTypesStruct.boolean)
                    if strcmp(ansi_boolean.val,ansi_int8.val)
                        boolean_is_int8 = 1;
                    elseif strcmp(ansi_boolean.val,ansi_uint16.val)
                        boolean_is_uint16 = 1;
                    elseif strcmp(ansi_boolean.val,ansi_int16.val)
                        boolean_is_int16 = 1;
                    elseif strcmp(ansi_boolean.val,ansi_uint32.val)
                        boolean_is_uint32 = 1;
                    elseif strcmp(ansi_boolean.val,ansi_int32.val)
                        boolean_is_int32 = 1;
                    end
                end
            end

            % Put out the appropriate typedef for boolean
            if boolean_is_int8
                if ~isempty(schar_name)
                    fprintf(f, '%s\n', ['typedef ' schar_name  ' boolean_T;']);
                end
            elseif boolean_is_int16
                if ~isempty(sName)
                    fprintf(f, '%s\n', ['typedef ' sName  ' boolean_T;']);
                end
            elseif boolean_is_int32
                if ~isempty(sint_name)
                    fprintf(f, '%s\n', ['typedef ' sint_name  ' boolean_T;']);
                end
            elseif boolean_is_uint16
                if ~isempty(uName)
                    fprintf(f, '%s\n', ['typedef ' uName  ' boolean_T;']);
                end
            elseif boolean_is_uint32
                if ~isempty(uint_name)
                    fprintf(f, '%s\n', ['typedef ' uint_name  ' boolean_T;']);
                end
            else
                % default: boolean is unsigned char
                if ~isempty(uchar_name)
                    fprintf(f, '%s\n', ['typedef ' uchar_name  ' boolean_T;']);
                end
            end
            
            % Put out int_T and uint_T
            if ~isempty(sint_name)
                fprintf(f, '%s\n', ['typedef ' sint_name  ' int_T;']);
            end
            if ~isempty(uint_name)
                fprintf(f, '%s\n', ['typedef ' uint_name  ' uint_T;']);
            end

            [uName, ~] = locMapToHost(hostWordLengths, hardwareDeploy, hardwareDeploy.LongNumBits);
            fprintf(f, '%s\n', ['typedef ' uName  ' ulong_T;']);
            
            %Can't use target char size due to string manipulations
            % (get this error from rt_logging.c:
            %  error: wchar_t-array initialized from non-wide string)
            fprintf(f, '%s\n', 'typedef char char_T;');
            fprintf(f, '%s\n', 'typedef unsigned char uchar_T;');
            fprintf(f, '%s\n', 'typedef char_T byte_T;  ');
            
            deploySizes = [hardwareDeploy.CharNumBits ...
                hardwareDeploy.ShortNumBits ...
                hardwareDeploy.IntNumBits ...
                hardwareDeploy.LongNumBits];
            [~, IA, ~] = intersect(64, deploySizes);
            if ~isempty(IA)
                [uName, sName] = locMapToHost(hostWordLengths, hardwareDeploy, 64);
                fprintf(f, '%s\n', ['typedef ' sName  ' int64_T;']);
                fprintf(f, '%s\n', ['typedef ' uName ' uint64_T;']);
            end
            
            fprintf(f, '%s\n', '#else  /* PORTABLE_WORDSIZES not defined */ ');
        end
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/*=======================================================================*  ');
        fprintf(f, '%s\n', ' * Fixed width word size data types:                                     *  ');
        fprintf(f, '%s\n', ' *   int8_T, int16_T, int32_T     - signed 8, 16, or 32 bit integers     *  ');
        fprintf(f, '%s\n', ' *   uint8_T, uint16_T, uint32_T  - unsigned 8, 16, or 32 bit integers   *  ');
        if ~configInfo.PurelyIntegerCode
        fprintf(f, '%s\n', ' *   real32_T, real64_T           - 32 and 64 bit floating point numbers *  ');
        end

        if ~ideal_ansi_sizes
            fprintf(f, '%s\n', ' *                                                                       *  ');
            fprintf(f, '%s\n', ' *                                                                       *  ');
            fprintf(f, '%s\n', ' *   Note:  Because the specified hardware does not have native support  *  ');
            fprintf(f, '%s\n', ' *          for all data sizes, some data types are actually typedef''ed  *  ');
            fprintf(f, '%s\n', ' *          from larger native data sizes.  The following data types are *  ');
            fprintf(f, '%s\n', ' *          not in the ideal native data types:                          *  ');
            fprintf(f, '%s\n', ' *                                                                       *  ');
            if ~ansi_int8.native_support
                fprintf(f, '%s\n', ' *          int8_T, uint8_T                                              *  ');
            end
            if ~ansi_int16.native_support
                fprintf(f, '%s\n', ' *          int16_T, uint16_T                                            *  ');
            end
            if ~ansi_int32.native_support
                fprintf(f, '%s\n', ' *          int32_T, uint32_T                                            *  ');
            end    
        end

        fprintf(f, '%s\n', ' *=======================================================================*/  ');
        fprintf(f, '%s\n', '  ');

        if ~isempty(ansi_int8.val)
            fprintf(f, '%s\n', ['typedef ' ansi_int8.val   ' int8_T;']);
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.int8, 'int8_T', SUPPORT_COMPLEX);
            end
        end
        if ~isempty(ansi_uint8.val)
            fprintf(f, '%s\n', ['typedef ' ansi_uint8.val  ' uint8_T;']);
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.uint8, 'uint8_T', SUPPORT_COMPLEX);
            end
        end
        if ~isempty(ansi_int16.val)
            fprintf(f, '%s\n', ['typedef ' ansi_int16.val  ' int16_T;']);
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.int16, 'int16_T', SUPPORT_COMPLEX);
            end
        end
        if ~isempty(ansi_uint16.val)
            fprintf(f, '%s\n', ['typedef ' ansi_uint16.val ' uint16_T;']);
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.uint16, 'uint16_T', SUPPORT_COMPLEX);
            end
        end
        if ~isempty(ansi_int32.val)
            fprintf(f, '%s\n', ['typedef ' ansi_int32.val  ' int32_T;']);
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.int32, 'int32_T', SUPPORT_COMPLEX);
            end
        end
        if ~isempty(ansi_uint32.val)
            fprintf(f, '%s\n', ['typedef ' ansi_uint32.val ' uint32_T;']);
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.uint32, 'uint32_T', SUPPORT_COMPLEX);
            end
        end
        if ~isempty(ansi_int64.val)
            fprintf(f, '%s\n', ['typedef ' ansi_int64.val  ' int64_T;']);
        end
        if ~isempty(ansi_uint64.val)
            fprintf(f, '%s\n', ['typedef ' ansi_uint64.val ' uint64_T;']);
        end

        if ~isempty(ansi_real32.val)
            fprintf(f, '%s\n', ['typedef ' ansi_real32.val ' real32_T;']);
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.single, 'real32_T', SUPPORT_COMPLEX);
            end
        end
        if ~isempty(ansi_real64.val)
            fprintf(f, '%s\n', ['typedef ' ansi_real64.val ' real64_T;']);
            % Note we're going to take care of the replacement type for 'double' below,
            % while taking care of the generic 'real_T' typedef.
        end

        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/*===========================================================================*  ');
        if isempty(ansi_real64.val)
        fprintf(f, '%s\n', ' * Generic type definitions: boolean_T, int_T, uint_T, ulong_T, char_T,      *  ');
        fprintf(f, '%s\n', ' *                           and byte_T.                                     *  ');
        else
        fprintf(f, '%s\n', ' * Generic type definitions: real_T, time_T, boolean_T, int_T, uint_T,       *  ');
        fprintf(f, '%s\n', ' *                           ulong_T, char_T and byte_T.                     *  ');
        end

        fprintf(f, '%s\n', ' *===========================================================================*/  ');
        fprintf(f, '%s\n', '  ');

        if ~isempty(ansi_real64.val)
            fprintf(f, '%s\n', ['typedef ' ansi_real64.val ' real_T;']);
            % Take care of the 'double' replacement type
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.double, 'real_T', SUPPORT_COMPLEX);
            end
            fprintf(f, '%s\n', ['typedef ' ansi_real64.val ' time_T;']);
        elseif ~isempty(ansi_real32.val)
            fprintf(f, '%s\n', ['typedef ' ansi_real32.val ' real_T;']);
            % The following is a fallback for the case where a replacement type
            % for 'double' was defined, but there is no ansi_real64 type.
            % In that case we fall back to typedefing the 'double' replacement type
            % to 'real_T' which is typedef'ed to the ansi_real32 type.
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.double, 'real_T', SUPPORT_COMPLEX);
            end
            fprintf(f, '%s\n', ['typedef ' ansi_real32.val ' time_T;']);
        end

        if ~isempty(ansi_boolean.val)
            fprintf(f, '%s\n', ['typedef ' ansi_boolean.val ' boolean_T;']);
            if simulinkInfo.ReplacementTypesOn
                [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.boolean, 'boolean_T', SUPPORT_COMPLEX);
            end
        end

        %define int_T & uint_T
        ansi_int = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT');
        switch (ansi_int.numBits)
          case 8
            fprintf(f, '%s\n', ['typedef ' ansi_int8.val   ' int_T; ']);
            fprintf(f, '%s\n', ['typedef ' ansi_uint8.val  ' uint_T; ']);
          case 16
            fprintf(f, '%s\n', ['typedef ' ansi_int16.val  ' int_T; ']);
            fprintf(f, '%s\n', ['typedef ' ansi_uint16.val ' uint_T; ']);
          case 32
            fprintf(f, '%s\n', ['typedef ' ansi_int32.val  ' int_T; ']);
            fprintf(f, '%s\n', ['typedef ' ansi_uint32.val ' uint_T; ']);
          otherwise
            fprintf(f, '%s\n', 'typedef int int_T;  ');
            fprintf(f, '%s\n', 'typedef unsigned uint_T;  ');
        end
        if simulinkInfo.ReplacementTypesOn
            [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.int, 'int_T', SUPPORT_COMPLEX);
            [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.uint, 'uint_T', SUPPORT_COMPLEX);
        end

        fprintf(f, '%s\n', 'typedef unsigned long ulong_T;');

        %define char_T byte_T
        fprintf(f, '%s\n', 'typedef char char_T;  ');
        fprintf(f, '%s\n', 'typedef unsigned char uchar_T;  ');
        if simulinkInfo.ReplacementTypesOn
            [ReplaceTypeDefs ReplaceTypesHdrList] = loc_define_replacementtype(ReplaceTypeDefs, ReplaceTypesHdrList, simulinkInfo.ReplacementTypesStruct.char, 'char_T', SUPPORT_COMPLEX);
        end
        
        
        fprintf(f, '%s\n', 'typedef char_T byte_T;  ');
        fprintf(f, '%s\n', '  ');

        if (ENABLE_PORTABLE_WORDSIZES == 1)
            fprintf(f, '%s\n', '   ');
            fprintf(f, '%s\n', '#endif  /* PORTABLE_WORDSIZES */  ');
            fprintf(f, '%s\n', '   ');
        end
        
        if (SUPPORT_COMPLEX)
            fprintf(f, '%s\n', '/*===========================================================================*  ');
            fprintf(f, '%s\n', ' * Complex number type definitions                                           *  ');
            fprintf(f, '%s\n', ' *===========================================================================*/  ');
        end

        if (SUPPORT_COMPLEX)

            % define floating point reals
            if (ansi_support_fp)
                fprintf(f, '%s\n', '#define CREAL_T');
                fprintf(f, '%s\n', '  ');
                %define creal32_T
                if ~isempty(ansi_real32.val)
                    fprintf(f, '%s\n', '   typedef struct {  ');
                    fprintf(f, '%s\n', '     real32_T re;  ');
                    fprintf(f, '%s\n', '     real32_T im;  ');
                    fprintf(f, '%s\n', '   } creal32_T;  ');
                    fprintf(f, '%s\n', '  ');
                end            %REAL32_T_defined
                               %define creal64_T
                if ~isempty(ansi_real64.val)
                    fprintf(f, '%s\n', '   typedef struct {  ');
                    fprintf(f, '%s\n', '     real64_T re;  ');
                    fprintf(f, '%s\n', '     real64_T im;  ');
                    fprintf(f, '%s\n', '   } creal64_T;  ');
                    fprintf(f, '%s\n', '  ');
                end            %REAL64_T_defined
                
                %define creal_T
                if (~isempty(ansi_real64.val) || ~isempty(ansi_real32.val))
                    fprintf(f, '%s\n', '   typedef struct {  ');
                    fprintf(f, '%s\n', '     real_T re;  ');
                    fprintf(f, '%s\n', '     real_T im;  ');
                    fprintf(f, '%s\n', '   } creal_T;  ');
                    fprintf(f, '%s\n', '  ');
                end            %REAL64_T_defined
            end % floating point reals

            %define cint8_T
            if ~isempty(ansi_int8.val)
                fprintf(f, '%s\n', '   typedef struct {  ');
                fprintf(f, '%s\n', '     int8_T re;  ');
                fprintf(f, '%s\n', '     int8_T im;  ');
                fprintf(f, '%s\n', '   } cint8_T;  ');
                fprintf(f, '%s\n', '  ');
            end

            %define cuint8_T
            if ~isempty(ansi_uint8.val)
                fprintf(f, '%s\n', '   typedef struct {  ');
                fprintf(f, '%s\n', '     uint8_T re;  ');
                fprintf(f, '%s\n', '     uint8_T im;  ');
                fprintf(f, '%s\n', '   } cuint8_T;  ');
                fprintf(f, '%s\n', '  ');
            end
            
            %define cint16_T
            if ~isempty(ansi_int16.val)
                fprintf(f, '%s\n', '   typedef struct {  ');
                fprintf(f, '%s\n', '     int16_T re;  ');
                fprintf(f, '%s\n', '     int16_T im;  ');
                fprintf(f, '%s\n', '   } cint16_T;  ');
                fprintf(f, '%s\n', '  ');
            end

            %define cuint16_T
            if ~isempty(ansi_uint16.val)
                fprintf(f, '%s\n', '   typedef struct {  ');
                fprintf(f, '%s\n', '     uint16_T re;  ');
                fprintf(f, '%s\n', '     uint16_T im;  ');
                fprintf(f, '%s\n', '   } cuint16_T;  ');
                fprintf(f, '%s\n', '  ');
            end
            
            %define cint32_T
            if ~isempty(ansi_int32.val)
                fprintf(f, '%s\n', '   typedef struct {  ');
                fprintf(f, '%s\n', '     int32_T re;  ');
                fprintf(f, '%s\n', '     int32_T im;  ');
                fprintf(f, '%s\n', '   } cint32_T;  ');
                fprintf(f, '%s\n', '  ');
            end

            %define cuint32_T
            if ~isempty(ansi_uint32.val)
                fprintf(f, '%s\n', '   typedef struct {  ');
                fprintf(f, '%s\n', '     uint32_T re;  ');
                fprintf(f, '%s\n', '     uint32_T im;  ');
                fprintf(f, '%s\n', '   } cuint32_T;  ');
                fprintf(f, '%s\n', '  ');
            end

            %define cint64_T
            if ~isempty(ansi_int64.val)
                fprintf(f, '%s\n', '   typedef struct {  ');
                fprintf(f, '%s\n', '     int64_T re;  ');
                fprintf(f, '%s\n', '     int64_T im;  ');
                fprintf(f, '%s\n', '   } cint64_T;  ');
                fprintf(f, '%s\n', '  ');
            end

            %define cuint64_T
            if ~isempty(ansi_uint64.val)
                fprintf(f, '%s\n', '   typedef struct {  ');
                fprintf(f, '%s\n', '     uint64_T re;  ');
                fprintf(f, '%s\n', '     uint64_T im;  ');
                fprintf(f, '%s\n', '   } cuint64_T;  ');
                fprintf(f, '%s\n', '  ');
            end
            
        end           % (SUPPORT_COMPLEX)

        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/*=======================================================================*  ');
        fprintf(f, '%s\n', ' * Min and Max:                                                          *  ');
        fprintf(f, '%s\n', ' *   int8_T, int16_T, int32_T     - signed 8, 16, or 32 bit integers     *  ');
        fprintf(f, '%s\n', ' *   uint8_T, uint16_T, uint32_T  - unsigned 8, 16, or 32 bit integers   *  ');
        fprintf(f, '%s\n', ' *=======================================================================*/  ');
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '#define  MAX_int8_T      ((int8_T)(127))              ');
        fprintf(f, '%s\n', '#define  MIN_int8_T      ((int8_T)(-128))             ');
        fprintf(f, '%s\n', '#define  MAX_uint8_T     ((uint8_T)(255U))             ');
        fprintf(f, '%s\n', '#define  MIN_uint8_T     ((uint8_T)(0U))  ');
        fprintf(f, '%s\n', '#define  MAX_int16_T     ((int16_T)(32767))           ');
        fprintf(f, '%s\n', '#define  MIN_int16_T     ((int16_T)(-32768))          ');
        fprintf(f, '%s\n', '#define  MAX_uint16_T    ((uint16_T)(65535U))          ');
        fprintf(f, '%s\n', '#define  MIN_uint16_T    ((uint16_T)(0U))  ');
        fprintf(f, '%s\n', '#define  MAX_int32_T     ((int32_T)(2147483647))      ');
        fprintf(f, '%s\n', '#define  MIN_int32_T     ((int32_T)(-2147483647-1))   ');
        fprintf(f, '%s\n', '#define  MAX_uint32_T    ((uint32_T)(0xFFFFFFFFU))    ');
        fprintf(f, '%s\n', '#define  MIN_uint32_T    ((uint32_T)(0U))  ');
        % 2^63 =  9223372036854775808L
        if ~isempty(ansi_int64.val)
            fprintf(f, '%s\n', '#define  MAX_int64_T     ((int64_T)(9223372036854775807L))     ');
            fprintf(f, '%s\n', '#define  MIN_int64_T     ((int64_T)(-9223372036854775807L-1L)) ');
        end
        if ~isempty(ansi_uint64.val)
            fprintf(f, '%s\n', '#define  MAX_uint64_T    ((uint64_T)(0xFFFFFFFFFFFFFFFFUL)) ');
            fprintf(f, '%s\n', '#define  MIN_uint64_T    ((uint64_T)(0UL))  ');

        end

        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/* Logical type definitions */  ');
        fprintf(f, '%s\n', '#if (!defined(__cplusplus)) && (!defined(__true_false_are_keywords))  ');
        fprintf(f, '%s\n', '#  ifndef false');                                     
        fprintf(f, '%s\n', '#   define false (0U)');                                
        fprintf(f, '%s\n', '#  endif');                                            
        fprintf(f, '%s\n', '#  ifndef true   ');                                   
        fprintf(f, '%s\n', '#   define true (1U)');                                 
        fprintf(f, '%s\n', '#  endif  ');                                          
        fprintf(f, '%s\n', '#endif');                     
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/*   ');
        fprintf(f, '%s\n', ' * Real-Time Workshop assumes the code is compiled on a target using a 2''s compliment representation');
        fprintf(f, '%s\n', ' * for signed integer values.    ');
        fprintf(f, '%s\n', ' */  ');
        fprintf(f, '%s\n', '#if ((SCHAR_MIN + 1) != -SCHAR_MAX)  ');
        fprintf(f, '%s\n', '#error "This code must be compiled using a 2''s complement representation for signed integer values"  ');
        fprintf(f, '%s\n', '#endif  ');
        fprintf(f, '%s\n', '  ');
        % define rtwtypes ID so that an incorrect rtwtypes.h inclusion can be detected
        fprintf(f, '%s\n', '/* This ID is used to detect inclusion of an incompatible rtwtypes.h */');
        fprintf(f, '%s\n', ['#define ' ansi_data_type_size_checksum.val ]);
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '#else  /* __TMWTYPES__ */  ');
        fprintf(f, '%s\n', '#define TMWTYPES_PREVIOUSLY_INCLUDED');
        fprintf(f, '%s\n', '#endif /* __TMWTYPES__ */  ');
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/* Block D-Work pointer type */');
        fprintf(f, '%s\n', 'typedef void * pointer_T;   ');
        fprintf(f, '%s\n', '  ');

        % emit additional typedef's
        dumpAdditionalTypeDefs(f, ansiDataTypeTable, false, hardwareDeploy, ...
            ENABLE_PORTABLE_WORDSIZES, hostWordLengths);

        % emit additional complex types
        dumpAdditionalComplexTypes(f, ansiDataTypeTable, SUPPORT_COMPLEX, true, false);

        % Conditionally emit MultiWord type definitions
        dumpMultiWordTypeDefs(f, ...
                              simulinkInfo.GenChunkDefs, ...                              
                              ansiDataTypeTable, ...
                              'chunks', ...
                              SUPPORT_COMPLEX, ...
                              MaxMultiwordBits, ...
                              hardwareDeploy, ...
                              ENABLE_PORTABLE_WORDSIZES, ...
                              hostWordLengths);

        % emit RTW replacement data types
        if simulinkInfo.ReplacementTypesOn && ...
                ~(isempty(ReplaceTypesHdrList) && isempty(ReplaceTypeDefs))
            fprintf(f, '%s\n', '  ');
            fprintf(f, '%s\n', '/* Define RTW replacement data types. */  ');
            for i=1:length(ReplaceTypesHdrList)
                DataTypeList='';
                for j=1:length(ReplaceTypesHdrList{i}.DataTypes)
                    DataTypeList = [DataTypeList ReplaceTypesHdrList{i}.DataTypes{j} ' ']; %#ok
                end
                %check delimiters
                rheader = ReplaceTypesHdrList{i}.HeaderFile;
                if (rheader(1)=='"' && rheader(end)=='"') ||...
                        (rheader(1)=='<' && rheader(end)=='>')
                    fprintf(f, '%s\n', ['  #include ' ReplaceTypesHdrList{i}.HeaderFile ' /* User defined replacement datatype for ' DataTypeList ' */ ']);
                else
                    fprintf(f, '%s\n', ['  #include "' ReplaceTypesHdrList{i}.HeaderFile '" /* User defined replacement datatype for ' DataTypeList ' */ ']);
                end
            end
            fprintf(f, '%s\n', ReplaceTypeDefs);
            fprintf(f, '%s\n', '  ');
        end

        if usingSimulink
            fprintf(f, '%s\n', '/* Simulink specific types */  ');
            fprintf(f, '%s\n', '  ');
            fprintf(f, '%s\n', '#ifndef __SIMSTRUC_TYPES_H__  ');
            fprintf(f, '%s\n', '#define __SIMSTRUC_TYPES_H__  ');
            simstrc_types_buffer = rtwprivate('gen_simstruc_types', ...
                                              configInfo.PurelyIntegerCode, ...
                                              simulinkInfo);
            fprintf(f, '%s\n', simstrc_types_buffer);
            fprintf(f, '%s\n', '#endif  /* __SIMSTRUC_TYPES_H__ */  ');
            fprintf(f, '%s\n', '#endif /* __RTWTYPES_H__ */  ');
        end
        fclose(f);

    catch last_error_msg_id
        ansiDataTypeName = false; %#ok
        if f ~= -1
            fclose(f); % make sure close handle
        end
        rethrow(last_error_msg_id);
    end

    c_beautifier(tmwtypesFile);
    return

% Function: loc_define_replacementtype()
%   This takes care of building up the typedefs to support the 
%   Data Type Replacement dialog. This is called for each replacement type, 
%   to append its typedef to the string being built up. 
%   'baseName' is the base type, e.g. 'int32_T' or 'boolean_T' or ...
%   AliasData is the alias name, i.e. what appeared in the
%   Replacement Type dialog. So for example if baseName is 'int8_T'
%   and AliasData is 's1', we'll end up putting out
%   typedef int8_T s1;
%   The 's' in/out argument is the string of typedefs we have built up so far,
%   which we use to avoid putting out duplicate typedefs.
%   
function [s, ReplaceTypesHdrList] = loc_define_replacementtype(s, ReplaceTypesHdrList, AliasData, baseName, support_complex)
    if ~isempty(AliasData)

        [~,aHeader] = rtwprivate('findBaseType',AliasData);

        % See if AliasData specifies a header file
        if ~isempty(aHeader)
            foundMatch = false;
            for i=1:length(ReplaceTypesHdrList)
                if strcmp(aHeader, ReplaceTypesHdrList{i}.HeaderFile)
                    ReplaceTypesHdrList{i}.DataTypes{end+1} = baseName;
                    foundMatch = true;
                    break;
                end
            end
            if ~foundMatch
                ReplaceTypesHdrList{end+1}.HeaderFile = aHeader;
                ReplaceTypesHdrList{end}.DataTypes{1} = baseName;
            end
        else

            % If we get here, 'AliasData' is a name to be typedef'ed to type 'baseName'.
            % We want to avoid putting out duplicate typedefs. 
            % Checking for this is based on seeing if the typedef we are
            % about to put out is a substring of what we've already put out.
            % We have to be a bit careful about how we go about this.
            % For example, we want to put out only 1 of these 2 redundant typedefs:
            %   typedef int32_T s1; /* User defined ...  
            %   typedef int_T s1; /* User defined ...  
            % However, we want to put out both of the following and not be fooled 
            % by the fact that "s1" is a substring of "s1s1". 
            %   typedef int16_T s1; /* User defined replacement datatype for ...  
            %   typedef int32_T s1s1; /* User defined replacement datatype for ...  
            % Therefore we are careful to include the space before the alias name
            % in the duplicate check string, but not include the base type name.
            dupChkStr = [' ' AliasData '; /* User defined replacement datatype for '];
            if isempty(strfind(s, dupChkStr))  
                s = [s sprintf('%s\n', ['  typedef ' baseName ' ' AliasData '; /* User defined replacement datatype for ' baseName ' */'])];
                % For compatibility with user-defined types, it is necessary
                % to also put out the complex typename. For example, if
                % x1 is a Simulink.AliasType object whose base type is 'int32', 
                % then you can use x1 or cx1 directly in the model,
                % and these need to be typedef'ed to int32_T and cint32_T respectively.
                % However, only do this for the base types that actually *have*
                % complex typenames associated with them.
                if support_complex && ...
                  ((strcmp(baseName, 'real32_T')) || (strcmp(baseName, 'real64_T')) || ...
                   (strcmp(baseName, 'real_T')) || ...
                   (strcmp(baseName, 'int8_T')) || (strcmp(baseName, 'uint8_T')) || ...
                   (strcmp(baseName, 'int16_T')) || (strcmp(baseName,'uint16_T')) || ...
                   (strcmp(baseName, 'int32_T')) || (strcmp(baseName, 'uint32_T')))
                    cAliasData = ['c' AliasData];
                    cBaseName = ['c' baseName];
                    s = [s sprintf('%s\n', ['  typedef ' cBaseName ' ' cAliasData '; /* User defined replacement datatype for ' cBaseName ' */'])];
                end
            end
        end
    end

function dumpAdditionalTypeDefs(f, ansiDataTypeTable, ...
    needMicroProtectionFor64Bits, hardwareDeploy, portWordSizes, hostWordLengths)

    if (needMicroProtectionFor64Bits) 
        ansi_int64         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT64');
        ansi_uint64        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT64');
        ansi_int64.numBits  = 64;
        ansi_uint64.numBits = 64;
        ansi_int64.typeName  = 'int64_T';
        ansi_uint64.typeName = 'uint64_T';

        locUtilDumpTypeDef(f, ansi_int64, needMicroProtectionFor64Bits);
        locUtilDumpTypeDef(f, ansi_uint64, needMicroProtectionFor64Bits);
    end

    ansi_char_deploy          = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_CHAR_DEPLOY');
    ansi_uchar_deploy         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UCHAR_DEPLOY');
    ansi_short_deploy         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_SHORT_DEPLOY');
    ansi_ushort_deploy        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_USHORT_DEPLOY');
    ansi_int_deploy           = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT_DEPLOY');
    ansi_uint_deploy          = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT_DEPLOY');
    ansi_long_deploy          = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_LONG_DEPLOY');
    ansi_ulong_deploy         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_ULONG_DEPLOY');

    needAdditionalHardwareDefinitions = false;
    if ~isempty(ansi_char_deploy.val) || ...
            ~isempty(ansi_short_deploy.val) || ...
            ~isempty(ansi_int_deploy.val) || ...
            ~isempty(ansi_long_deploy.val)
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/*===========================================================================*  ');
        fprintf(f, '%s\n', ' * Additional type definitions: Embedded Hardware                            *  ');
        fprintf(f, '%s\n', ' *===========================================================================*/  ');
        fprintf(f, '%s\n', '  ');
        needAdditionalHardwareDefinitions = true;
        if (portWordSizes == 1)
            fprintf(f, '%s\n', '   ');
            fprintf(f, '%s\n', '#ifdef PORTABLE_WORDSIZES   /* PORTABLE_WORDSIZES defined */');
            fprintf(f, '%s\n', '  ');
            if ~isempty(ansi_char_deploy.val)
                numBits = hardwareDeploy.CharNumBits;
                uTypeName = ['uint', num2str(numBits), '_T'];
                typeName  = ['int',  num2str(numBits), '_T'];
                [uchar_name, schar_name] = locMapToHost(hostWordLengths, hardwareDeploy, numBits);
                fprintf(f, '%s\n', ['typedef ', schar_name, ' ', typeName, ';']);
                fprintf(f, '%s\n', ['typedef ', uchar_name, ' ', uTypeName, ';']);
            end
            if ~isempty(ansi_short_deploy.val)
                numBits = hardwareDeploy.ShortNumBits;
                uTypeName = ['uint', num2str(numBits), '_T'];
                typeName  = ['int',  num2str(numBits), '_T'];
                [uchar_name, schar_name] = locMapToHost(hostWordLengths, hardwareDeploy, numBits);
                fprintf(f, '%s\n', ['typedef ', schar_name, ' ', typeName, ';']);
                fprintf(f, '%s\n', ['typedef ', uchar_name, ' ', uTypeName, ';']);
            end
            if ~isempty(ansi_int_deploy.val)
                numBits = hardwareDeploy.IntNumBits;
                uTypeName = ['uint', num2str(numBits), '_T'];
                typeName  = ['int',  num2str(numBits), '_T'];
                [uchar_name, schar_name] = locMapToHost(hostWordLengths, hardwareDeploy, numBits);
                fprintf(f, '%s\n', ['typedef ', schar_name, ' ', typeName, ';']);
                fprintf(f, '%s\n', ['typedef ', uchar_name, ' ', uTypeName, ';']);
            end
            if ~isempty(ansi_long_deploy.val)
                numBits = hardwareDeploy.LongNumBits;
                uTypeName = ['uint', num2str(numBits), '_T'];
                typeName  = ['int',  num2str(numBits), '_T'];
                [uchar_name, schar_name] = locMapToHost(hostWordLengths, hardwareDeploy, numBits);
                fprintf(f, '%s\n', ['typedef ', schar_name, ' ', typeName, ';']);
                fprintf(f, '%s\n', ['typedef ', uchar_name, ' ', uTypeName, ';']);
            end
            fprintf(f, '%s\n', '   ');
            fprintf(f, '%s\n', '#else  /* PORTABLE_WORDSIZES not defined */ ');
            fprintf(f, '%s\n', '   ');
        end
    end
    
    locUtilDumpTypeDef(f, ansi_char_deploy, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_uchar_deploy, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_short_deploy, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_ushort_deploy, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_int_deploy, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_uint_deploy, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_long_deploy, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_ulong_deploy, needMicroProtectionFor64Bits);

    ansi_char                 = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_CHAR');
    ansi_uchar                = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UCHAR');
    ansi_short                = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_SHORT');
    ansi_ushort               = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_USHORT');
    ansi_int                  = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT');
    ansi_uint                 = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT');
    ansi_long                 = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_LONG');
    ansi_ulong                = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_ULONG');

    if ~isempty(ansi_char.val) || ...
            ~isempty(ansi_short.val) || ...
            ~isempty(ansi_int.val) || ...
            ~isempty(ansi_long.val)
        fprintf(f, '%s\n', '  ');
        fprintf(f, '%s\n', '/*===========================================================================*  ');
        fprintf(f, '%s\n', ' * Additional type definitions: Emulation Hardware                           *  ');
        fprintf(f, '%s\n', ' *===========================================================================*/  ');
        fprintf(f, '%s\n', '  ');
    end

    locUtilDumpTypeDef(f, ansi_char, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_uchar, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_short, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_ushort, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_int, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_uint, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_long, needMicroProtectionFor64Bits);
    locUtilDumpTypeDef(f, ansi_ulong, needMicroProtectionFor64Bits);
    if (portWordSizes == 1 && needAdditionalHardwareDefinitions)
        fprintf(f, '%s\n', '   ');
        fprintf(f, '%s\n', '#endif  /* PORTABLE_WORDSIZES */  ');
        fprintf(f, '%s\n', '   ');
    end

%endfunction

function dumpAdditionalComplexTypes(f, ansiDataTypeTable, SUPPORT_COMPLEX, showComments, needMicroProtectionFor64Bits)

    if (SUPPORT_COMPLEX)
        
        ansi_char_deploy          = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_CHAR_DEPLOY');
        ansi_uchar_deploy         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UCHAR_DEPLOY');
        ansi_short_deploy         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_SHORT_DEPLOY');
        ansi_ushort_deploy        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_USHORT_DEPLOY');
        ansi_int_deploy           = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT_DEPLOY');
        ansi_uint_deploy          = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT_DEPLOY');
        ansi_long_deploy          = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_LONG_DEPLOY');
        ansi_ulong_deploy         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_ULONG_DEPLOY');
        ansi_char                 = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_CHAR');
        ansi_uchar                = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UCHAR');
        ansi_short                = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_SHORT');
        ansi_ushort               = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_USHORT');
        ansi_int                  = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT');
        ansi_uint                 = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT');
        ansi_long                 = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_LONG');
        ansi_ulong                = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_ULONG');
        
        moreCondition = false;

        if needMicroProtectionFor64Bits
            ansi_int64         = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_INT64');
            ansi_uint64        = rtwprivate('getAnsiDataType',ansiDataTypeTable,'tSS_UINT64');
            ansi_int64.numBits   = 64;
            ansi_uint64.numBits  = 64;
            ansi_int64.typeName  = 'int64_T';
            ansi_uint64.typeName = 'uint64_T';

            moreCondition = ~isempty(ansi_int64.val) || ~isempty(ansi_uint64.val);
        end
        
        if showComments
            if ~isempty(ansi_uchar_deploy.val) || ...
                    ~isempty(ansi_char_deploy.val) || ...
                    ~isempty(ansi_uchar.val) || ...
                    ~isempty(ansi_char.val) || ...
                    ~isempty(ansi_ushort_deploy.val) || ...
                    ~isempty(ansi_short_deploy.val) || ...
                    ~isempty(ansi_ushort.val) || ...
                    ~isempty(ansi_short.val) || ...
                    ~isempty(ansi_uint_deploy.val) || ...
                    ~isempty(ansi_int_deploy.val) || ...
                    ~isempty(ansi_uint.val) || ...
                    ~isempty(ansi_int.val) || ...
                    ~isempty(ansi_ulong_deploy.val) || ...
                    ~isempty(ansi_long_deploy.val) || ...
                    ~isempty(ansi_ulong.val) || ...
                    ~isempty(ansi_long.val) || ...
                    moreCondition
                
                
                fprintf(f, '\n');
                fprintf(f, '%s\n', '/*===========================================================================*  ');
                fprintf(f, '%s\n', ' * Additional complex number type definitions                                           *  ');
                fprintf(f, '%s\n', ' *===========================================================================*/  ');
            end
        end

        if needMicroProtectionFor64Bits
            locUtilDumpComplexTypeDef(f, ansi_int64, needMicroProtectionFor64Bits);
            locUtilDumpComplexTypeDef(f, ansi_uint64, needMicroProtectionFor64Bits);
        end

        locUtilDumpComplexTypeDef(f, ansi_char_deploy, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_uchar_deploy, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_short_deploy, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_ushort_deploy, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_int_deploy, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_uint_deploy, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_long_deploy, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_ulong_deploy, needMicroProtectionFor64Bits);


        locUtilDumpComplexTypeDef(f, ansi_char, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_uchar, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_short, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_ushort, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_int, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_uint, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_long, needMicroProtectionFor64Bits);
        locUtilDumpComplexTypeDef(f, ansi_ulong, needMicroProtectionFor64Bits);

    end
%endfunction

function locUtilDumpTypeDef(f, ansi_type, needMicroProtectionFor64Bits)

    addMicro = needMicroProtectionFor64Bits && (ansi_type.numBits == 64);

    if ~isempty(ansi_type.val)
        if addMicro
            if strncmpi(ansi_type.val, 'unsigned', size('unsigned',2))
                fprintf(f, '%s\n', '#ifndef UINT64_T');
                fprintf(f, '%s\n', '#define UINT64_T');
            else
                fprintf(f, '%s\n', '#ifndef INT64_T');
                fprintf(f, '%s\n', '#define INT64_T');
            end
        end
        fprintf(f, '%s\n', ['typedef ', ansi_type.val, ' ', ansi_type.typeName, ';']);
        if addMicro
            fprintf(f, '%s\n', '#endif');
        end
    end

function locUtilDumpComplexTypeDef(f, ansi_type, needMicroProtectionFor64Bits)

    if ~isempty(ansi_type.val)
        addMicro = needMicroProtectionFor64Bits && (ansi_type.numBits == 64);
        
        if addMicro
            if strncmpi(ansi_type.val, 'unsigned', size('unsigned',2))
                fprintf(f, '%s\n', '#ifndef CUINT64_T');
                fprintf(f, '%s\n', '#define CUINT64_T');
            else
                fprintf(f, '%s\n', '#ifndef CINT64_T');
                fprintf(f, '%s\n', '#define CINT64_T');
            end
        end
        if ~isempty(ansi_type.val)
            fprintf(f, '%s\n', '   typedef struct {  ');
            fprintf(f, '%s\n', ['     ', ansi_type.typeName, ' re;  ']);
            fprintf(f, '%s\n', ['     ', ansi_type.typeName, ' im;  ']);
            fprintf(f, '%s\n', ['   } c', ansi_type.typeName, ';  ']);
            fprintf(f, '%s\n', '  ');
        end
        if addMicro
            fprintf(f, '%s\n', '#endif');
        end
    end

function dumpMultiWordTypeDefs(f, ...
                               genChunkDefs, ...
                               ansiDataTypeTable, ...
                               chunksFieldName, ...
                               SUPPORT_COMPLEX, ...
                               MAX_MULTIWORD_BITS, ...
                               hardwareDeploy, ...
                               portWordSizes, ...
                               hostWordLengths)
%DUMPMULTIWORDTYPEDEFS
%
% tbpl: target bits per long
% tbpi: target bits per int
%
    ansi_long = rtwprivate('getAnsiDataType',ansiDataTypeTable, 'tSS_LONG');
    tbpl = double(ansi_long.numBits);
    % Write out supporting definitions for portable wordsize
    if genChunkDefs
        fprintf(f, '\n/*\n * Definitions supporting external data access \n */\n');
        
        fprintf(f, 'typedef int%s_T chunk_T;\n', num2str(tbpl));
        fprintf(f, 'typedef uint%s_T uchunk_T;\n', num2str(tbpl));
    end
    
    if (MAX_MULTIWORD_BITS <= tbpl)
        return
    end

    % Write out supporting definitions for multiword types
    fprintf(f, '\n/*\n * MultiWord supporting definitions\n */\n');

    if portWordSizes
        fprintf(f, '%s\n', '   ');
        fprintf(f, '%s\n', '#ifdef PORTABLE_WORDSIZES   /* PORTABLE_WORDSIZES defined */');
        numBits = hardwareDeploy.LongNumBits;
        [~, s_name] = locMapToHost(hostWordLengths, hardwareDeploy, numBits);
        fprintf(f, '%s\n', ['typedef ', s_name, ' long_T;']);
        fprintf(f, '%s\n', '   ');
        fprintf(f, '%s\n', '#else  /* PORTABLE_WORDSIZES not defined */ ');
        fprintf(f, '%s\n', '   ');
    end
    
    fprintf(f, 'typedef long int long_T;\n');

    if portWordSizes
        fprintf(f, '%s\n', '   ');
        fprintf(f, '%s\n', '#endif  /* PORTABLE_WORDSIZES */  ');
        fprintf(f, '%s\n', '   ');
    end
    
    % Write out the types
    % Ensure we cover at least the specified lengths. 
    fprintf(f, '\n/*\n * MultiWord types\n */\n');
    signednessPrefix = {'', 'u'}; % 'u' for unsigned
    for nBits = (2*tbpl : tbpl : (MAX_MULTIWORD_BITS + tbpl-1))
        % Write out types for all multiple of chunks,
        % starting with 2 chunks and up to 2048 bits.
        nChunks = nBits / tbpl;
        for sIndex = 1:2
            % Write out a type for each signedness mode
           
            typeName = [signednessPrefix{sIndex} 'int' num2str(nBits) 'm_T'];
            cTypeName = ['c' typeName];
           
            fprintf(f, '\n');

            % Real
            fprintf(f, '\ntypedef struct {\n');
            
            fprintf(f, '  uint%d_T %s[%d];\n', tbpl, chunksFieldName, nChunks);
            
            fprintf(f, '} %s;\n\n', typeName);

            % Complex
            if (SUPPORT_COMPLEX == 1)
               fprintf(f, 'typedef struct {\n');
               fprintf(f, '  %s re;\n', typeName);
               fprintf(f, '  %s im;\n', typeName);
               fprintf(f, '} %s;\n\n', cTypeName);
            end
    
        end
    end

%endfunction

%------------------------------------------------------------------------------
%
% function: locCheckArgs 
%
% inputs:
%
%------------------------------------------------------------------------------
function locCheckArgs(hardwareImp, hardwareDeploy, configInfo, simulinkInfo)

    % Ensure arguments are appropriate
    expectedImp = {'CharNumBits', 'ShortNumBits', 'IntNumBits', 'LongNumBits',...
                   'WordSize', 'ShiftRightIntArith', 'IntDivRoundTo', 'Endianess',...
                   'FloatNumBits', 'DoubleNumBits', 'PointerNumBits', 'HWDeviceType'};
    optionalImp = {'TypeEmulationWarnSuppressLevel', 'PreprocMaxBitsSint',...
                   'PreprocMaxBitsUint'};
    impDiff = setdiff(fieldnames(hardwareImp),{expectedImp{:},optionalImp{:}}); %#ok<CCAT>
    if ~isempty(impDiff)
        if ~isempty(setdiff(impDiff,optionalImp))
            str = [sprintf('%s ',expectedImp{:}), '[ ',...
                           sprintf('%s ',optionalImp{:}),']'];
            DAStudio.error('RTW:buildProcess:invalidStructureArgument',...
                           'hardwareImp',str);
        end
    end

    expectedDeploy = {'CharNumBits', 'ShortNumBits', 'IntNumBits', 'LongNumBits', ...
                      'FloatNumBits', 'DoubleNumBits', 'PointerNumBits'};
    if ~isempty(setdiff(fieldnames(hardwareDeploy),expectedDeploy))
        str = sprintf('%s ',expectedDeploy{:});
        DAStudio.error('RTW:buildProcess:invalidStructureArgument',...
                       'hardwareDeploy',str);
    end

    expectedConfig = {'GenDirectory','PurelyIntegerCode','SupportComplex',...
                      'MaxMultiwordBits'}; 
    if ~isempty(setdiff(fieldnames(configInfo),expectedConfig))
        str = sprintf('%s ',expectedConfig{:});
        DAStudio.error('RTW:buildProcess:invalidStructureArgument',...
                       'configInfo',str);
    end

    expectedSimulink = {'Style','SharedLocation','IsERT','PortableWordSizes',...
                        'SupportNonInlinedSFcns','GRTInterface','ReplacementTypesOn',...
                        'ReplacementTypesStruct', 'GenChunkDefs', 'GenBuiltInDTEnums',...
                        'MatFileLogging', 'GenTimingBridge'};
    if ~isempty(setdiff(fieldnames(simulinkInfo),expectedSimulink))
        str = sprintf('%s ',expectedSimulink{:});
        DAStudio.error('RTW:buildProcess:invalidStructureArgument',...
                       'simulinkInfo',str);
    end
    
%------------------------------------------------------------------------------
%
% function: locMapToHost
%
% inputs:
%
%------------------------------------------------------------------------------
function [typeNameU, typeNameS] = locMapToHost(hostSizes, hardwareDeploy, numBits)
    typeNameU = []; %#ok<NASGU>
    typeNameS = []; %#ok<NASGU>
    if numBits <= hardwareDeploy.CharNumBits
        [typeNameU, typeNameS] = locGetHostEquivalent(hostSizes, ...
            hardwareDeploy.CharNumBits);
        
    elseif numBits <= hardwareDeploy.ShortNumBits
        [typeNameU, typeNameS] = locGetHostEquivalent(hostSizes, ...
            hardwareDeploy.ShortNumBits);
        
    elseif  numBits <= hardwareDeploy.IntNumBits
        [typeNameU, typeNameS] = locGetHostEquivalent(hostSizes, ...
            hardwareDeploy.IntNumBits);
        
    elseif  numBits <= hardwareDeploy.LongNumBits
        [typeNameU, typeNameS] = locGetHostEquivalent(hostSizes, ...
            hardwareDeploy.LongNumBits);
    else
        DAStudio.error('RTW:buildProcess:missingHostDataTypeForPortableWordSizes',...
                   numBits);
        
    end
    
%------------------------------------------------------------------------------
%
% function: locGetHostEquivalent
%
% inputs:
%
%------------------------------------------------------------------------------
function [typeNameU, typeNameS] = locGetHostEquivalent(hostSizes, numBits)
    typeNameU = []; %#ok<NASGU>
    typeNameS = []; %#ok<NASGU>
    if numBits <= hostSizes.CharNumBits
        typeNameU = 'unsigned char';
        typeNameS  = 'signed char';
        
    elseif numBits <= hostSizes.ShortNumBits
        typeNameU = 'unsigned short';
        typeNameS  = 'short';
        
    elseif  numBits <= hostSizes.IntNumBits
        typeNameU = 'unsigned int';
        typeNameS  = 'int';
        
    elseif  numBits <= hostSizes.LongNumBits
        typeNameU = 'unsigned long';
        typeNameS  = 'long';        
    else
        DAStudio.error('RTW:buildProcess:missingHostDataTypeForPortableWordSizes',...
                   numBits);
        
    end
