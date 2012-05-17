function hLib = tfl_table_addsub
%TFL_TABLE_ADDSUB - Provides custom entries for a Target Function Library table.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
% $Date: 2008/06/20 08:12:13 $

hLib = RTW.TflTable;


% Create an entry for addition of built-in uint8 data type
% Saturation on, Rounding as a don't care
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_ADD', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_UNSPECIFIED', ...
                                         'ImplementationName',       'u8_add_u8_u8', ...
                                         'ImplementationHeaderFile', 'u8_add_u8_u8.h', ...
                                         'ImplementationSourceFile', 'u8_add_u8_u8.c' );

arg = hLib.getTflArgFromString('y1','uint8');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u1','uint8');
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u2','uint8');
op_entry.addConceptualArg( arg );

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry( op_entry );


% Create an entry for addition of built-in uint16 data type
% Saturation off, Rounding to ceiling
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_ADD', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_WRAP_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_CEILING', ...
                                         'ImplementationName',       'u16_add_u16_u16', ...
                                         'ImplementationHeaderFile', 'u16_add_u16_u16.h', ...
                                         'ImplementationSourceFile', 'u16_add_u16_u16.c' );

arg = hLib.getTflArgFromString('y1','uint16');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u1','uint16');
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u2','uint16');
op_entry.addConceptualArg( arg );

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry( op_entry );


% Create an entry for addition of built-in int16 data type
% Saturation off, Rounding as simplest
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_ADD', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_WRAP_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_SIMPLEST', ...
                                         'ImplementationName',       's16_add_s16_s16', ...
                                         'ImplementationHeaderFile', 's16_add_s16_s16.h', ...
                                         'ImplementationSourceFile', 's16_add_s16_s16.c' );

arg = hLib.getTflArgFromString('y1','int16');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u1','int16');
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u2','int16');
op_entry.addConceptualArg( arg );

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry( op_entry );

% Create an entry for addition of built-in int16 data type
% Saturation on, Rounding as simplest
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_ADD', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_SIMPLEST', ...
                                         'ImplementationName',       's16_add_s16_s16', ...
                                         'ImplementationHeaderFile', 's16_add_s16_s16.h', ...
                                         'ImplementationSourceFile', 's16_add_s16_s16.c' );

arg = hLib.getTflArgFromString('y1','int16');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u1','int16');
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u2','int16');
op_entry.addConceptualArg( arg );

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry( op_entry );


% Create an entry for subtraction of built-in int16 data type
% Saturation on, Rounding to simplest
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_MINUS', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_SIMPLEST', ...
                                         'ImplementationName',       's16_sub_s16_s16', ...
                                         'ImplementationHeaderFile', 's16_sub_s16_s16.h', ...
                                         'ImplementationSourceFile', 's16_sub_s16_s16.c' );

arg = hLib.getTflArgFromString('y1','int16');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u1','int16');
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u2','int16');
op_entry.addConceptualArg( arg );

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry( op_entry );


% Create an entry for subtraction of built-in int8 data type
% Saturation on, Rounding to nearest
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_MINUS', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_NEAREST', ...
                                         'ImplementationName',       's8_sub_s8_s8', ...
                                         'ImplementationHeaderFile', 's8_sub_s8_s8.h', ...
                                         'ImplementationSourceFile', 's8_sub_s8_s8.c' );

arg = hLib.getTflArgFromString('y1','int8');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u1','int8');
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u2','int8');
op_entry.addConceptualArg( arg );

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry( op_entry );


% Create an entry for subtraction of built-in int32 data type
% Saturation as a don't care, Rounding to floor
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_MINUS', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_UNSPECIFIED', ...
                                         'RoundingMode',             'RTW_ROUND_FLOOR', ...
                                         'ImplementationName',       's32_sub_s32_s32', ...
                                         'ImplementationHeaderFile', 's32_sub_s32_s32.h', ...
                                         'ImplementationSourceFile', 's32_sub_s32_s32.c' );

arg = hLib.getTflArgFromString('y1','int32');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u1','int32');
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u2','int32');
op_entry.addConceptualArg( arg );

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry( op_entry );


% Create an entry for subtraction of built-in uint32 data type
% Saturation off, Rounding as a don't care
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_MINUS', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_WRAP_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_UNSPECIFIED', ...
                                         'ImplementationName',       'u32_sub_u32_u32', ...
                                         'ImplementationHeaderFile', 'u32_sub_u32_u32.h', ...
                                         'ImplementationSourceFile', 'u32_sub_u32_u32.c' );

arg = hLib.getTflArgFromString('y1','uint32');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u1','uint32');
op_entry.addConceptualArg( arg );

arg = hLib.getTflArgFromString('u2','uint32');
op_entry.addConceptualArg( arg );

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry( op_entry );
