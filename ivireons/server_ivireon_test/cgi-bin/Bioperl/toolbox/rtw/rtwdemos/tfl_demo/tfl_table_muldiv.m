function hLib = tfl_table_muldiv()
%TFL_TABLE_MULDIV - Provides custom entries for a Target Function Library table.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
% $Date: 2007/06/22 18:57:18 $

hLib = RTW.TflTable;

% Create an entry for multiplication of built-in int8 data type
% Saturation on, Rounding as a don't care
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_MUL', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_UNSPECIFIED', ...
                                         'ImplementationName',       's8_mul_s8_s8', ...
                                         'ImplementationHeaderFile', 's8_mul_s8_s8.h', ...
                                         'ImplementationSourceFile', 's8_mul_s8_s8.c');

arg = hLib.getTflArgFromString('y1','int8');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1','int8');
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2','int8');
op_entry.addConceptualArg(arg);

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry(op_entry);


% Create an entry for multiplication of built-in uint16 data type
% Saturation off, Rounding set to simplest
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_MUL', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_WRAP_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_SIMPLEST', ...
                                         'ImplementationName',       'u16_mul_u16_u16', ...
                                         'ImplementationHeaderFile', 'u16_mul_u16_u16.h', ...
                                         'ImplementationSourceFile', 'u16_mul_u16_u16.c');

arg = hLib.getTflArgFromString('y1','uint16');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1','uint16');
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2','uint16');
op_entry.addConceptualArg(arg);

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry(op_entry);


% Create an entry for multiplication of built-in int32 data type
% Saturation as a don't care, Rounding to zero
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_MUL', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_UNSPECIFIED', ...
                                         'RoundingMode',             'RTW_ROUND_ZERO', ...
                                         'ImplementationName',       's32_mul_s32_s32', ...
                                         'ImplementationHeaderFile', 's32_mul_s32_s32.h', ...
                                         'ImplementationSourceFile', 's32_mul_s32_s32.c');

arg = hLib.getTflArgFromString('y1','int32');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1','int32');
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2','int32');
op_entry.addConceptualArg(arg);

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry(op_entry);


% Create an entry for multiplication of mixed, built-in data types
% Saturation as a don't care, Rounding as a don't care
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_MUL', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_UNSPECIFIED', ...
                                         'RoundingMode',             'RTW_ROUND_UNSPECIFIED', ...
                                         'ImplementationName',       's32_mul_s8_u16', ...
                                         'ImplementationHeaderFile', 's32_mul_s8_u16.h', ...
                                         'ImplementationSourceFile', 's32_mul_s8_u16.c');

arg = hLib.getTflArgFromString('y1','int32');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1','int8');
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2','uint16');
op_entry.addConceptualArg(arg);

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry(op_entry);


% Create an entry for division of built-in uint8 data type
% Saturation off, Rounding to floor
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_DIV', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_WRAP_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_FLOOR', ...
                                         'ImplementationName',       'u8_div_u8_u8', ...
                                         'ImplementationHeaderFile', 'u8_div_u8_u8.h', ...
                                         'ImplementationSourceFile', 'u8_div_u8_u8.c');

arg = hLib.getTflArgFromString('y1','uint8');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1','uint8');
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2','uint8');
op_entry.addConceptualArg(arg);

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry(op_entry);


% Create an entry for division of built-in int16 data type
% Saturation off, Rounding to nearest
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_DIV', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_WRAP_ON_OVERFLOW', ...
                                         'RoundingMode',             'RTW_ROUND_NEAREST', ...
                                         'ImplementationName',       's16_div_s16_s16', ...
                                         'ImplementationHeaderFile', 's16_div_s16_s16.h', ...
                                         'ImplementationSourceFile', 's16_div_s16_s16.c');

arg = hLib.getTflArgFromString('y1','int16');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1','int16');
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2','int16');
op_entry.addConceptualArg(arg);

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry(op_entry);


% Create an entry for division of built-in uint32 data type
% Saturation as a don't care, Rounding as a don't care
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_DIV', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_UNSPECIFIED', ...
                                         'RoundingMode',             'RTW_ROUND_UNSPECIFIED', ...
                                         'ImplementationName',       'u32_div_u32_u32', ...
                                         'ImplementationHeaderFile', 'u32_div_u32_u32.h', ...
                                         'ImplementationSourceFile', 'u32_div_u32_u32.c');

arg = hLib.getTflArgFromString('y1','uint32');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1','uint32');
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2','uint32');
op_entry.addConceptualArg(arg);

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry(op_entry);


% Create an entry for division of mixed, built-in data types
% Saturation as a don't care, Rounding as a don't care
op_entry = RTW.TflCOperationEntry;
op_entry.setTflCOperationEntryParameters('Key',                      'RTW_OP_DIV', ...
                                         'Priority',                 90, ...
                                         'SaturationMode',           'RTW_SATURATE_UNSPECIFIED', ...
                                         'RoundingMode',             'RTW_ROUND_UNSPECIFIED', ...
                                         'ImplementationName',       's16_div_s16_u8', ...
                                         'ImplementationHeaderFile', 's16_div_s16_u8.h', ...
                                         'ImplementationSourceFile', 's16_div_s16_u8.c');

arg = hLib.getTflArgFromString('y1','int16');
arg.IOType = 'RTW_IO_OUTPUT';
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1','int16');
op_entry.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2','uint8');
op_entry.addConceptualArg(arg);

op_entry.copyConceptualArgsToImplementation();
hLib.addEntry(op_entry);
