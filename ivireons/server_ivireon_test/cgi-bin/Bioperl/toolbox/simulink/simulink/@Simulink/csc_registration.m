function defs = csc_registration(action)
% CSC_REGISTRATION Register custom storage classes.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2009/11/13 05:08:28 $


% Do not delete this line. Code below is auto-generated ========================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE:
% - This file was automatically generated by the Simulink custom storage class
%   designer.
% - The contents of this file are arranged so that the Simulink custom storage
%   class designer can load the associated classes for editing.
% - Hand modification of this file is not recommended as it may prevent the
%   Simulink custom storage class designer from loading the associated classes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Generated on:   13-Aug-2009 14:43:51
% - MATLAB version: 7.9.0.114310 (R2009b)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


switch action

  case 'CSCDefn'
    defs = [];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'BitField');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'FlatStructure');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', true);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', true);
    set(h, 'DataScope', 'Exported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Auto');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', false);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', 'Simulink.CSCTypeAttributes_FlatStructure');
        set(h.CSCTypeAttributes, 'StructName', '');
        set(h.CSCTypeAttributes, 'IsStructNameInstanceSpecific', true);
        set(h.CSCTypeAttributes, 'BitPackBoolean', true);
        set(h.CSCTypeAttributes, 'IsTypeDef', true);
        set(h.CSCTypeAttributes, 'TypeName', '');
        set(h.CSCTypeAttributes, 'TypeToken', '');
        set(h.CSCTypeAttributes, 'TypeTag', '');
    set(h, 'TLCFileName', 'FlatStructure.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'Const');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Unstructured');
    set(h, 'MemorySection', 'MemConst');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', false);
    set(h, 'DataScope', 'Exported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Auto');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', false);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'Unstructured.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'Volatile');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Unstructured');
    set(h, 'MemorySection', 'MemVolatile');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', true);
    set(h, 'DataScope', 'Exported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Auto');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', false);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'Unstructured.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'ConstVolatile');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Unstructured');
    set(h, 'MemorySection', 'MemConstVolatile');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', false);
    set(h, 'DataScope', 'Exported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Auto');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', false);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'Unstructured.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'Define');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Unstructured');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', false);
    set(h, 'DataScope', 'Exported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Macro');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', false);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'Unstructured.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'ImportedDefine');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Unstructured');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', false);
    set(h, 'DataScope', 'Imported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Macro');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', true);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'Unstructured.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'ExportToFile');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Unstructured');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', true);
    set(h, 'DataScope', 'Exported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Auto');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', true);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'Unstructured.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'ImportFromFile');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Unstructured');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', true);
    set(h, 'DataScope', 'Imported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'None');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', true);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'Unstructured.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'FileScope');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Unstructured');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', true);
    set(h, 'DataScope', 'File');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Auto');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', false);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'Unstructured.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'Struct');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'FlatStructure');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', true);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', true);
    set(h, 'DataScope', 'Exported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Auto');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', false);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', 'Simulink.CSCTypeAttributes_FlatStructure');
        set(h.CSCTypeAttributes, 'StructName', '');
        set(h.CSCTypeAttributes, 'IsStructNameInstanceSpecific', true);
        set(h.CSCTypeAttributes, 'BitPackBoolean', false);
        set(h.CSCTypeAttributes, 'IsTypeDef', true);
        set(h.CSCTypeAttributes, 'TypeName', '');
        set(h.CSCTypeAttributes, 'TypeToken', '');
        set(h.CSCTypeAttributes, 'TypeTag', '');
    set(h, 'TLCFileName', 'FlatStructure.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'GetSet');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Other');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', true);
    set(h, 'DataScope', 'Imported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'None');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', true);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', 'Simulink.CSCTypeAttributes_GetSet');
        set(h.CSCTypeAttributes, 'GetFunction', '');
        set(h.CSCTypeAttributes, 'SetFunction', '');
    set(h, 'TLCFileName', 'GetSet.tlc');
    defs = [defs; h];

    h = Simulink.CSCDefn;
    set(h, 'Name', 'CompilerFlag');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'CSCType', 'Other');
    set(h, 'MemorySection', 'Default');
    set(h, 'IsMemorySectionInstanceSpecific', false);
    set(h, 'IsGrouped', false);
        set(h.DataUsage, 'IsParameter', true);
        set(h.DataUsage, 'IsSignal', false);
    set(h, 'DataScope', 'Exported');
    set(h, 'IsDataScopeInstanceSpecific', false);
    set(h, 'DataInit', 'Macro');
    set(h, 'IsDataInitInstanceSpecific', false);
    set(h, 'DataAccess', 'Direct');
    set(h, 'IsDataAccessInstanceSpecific', false);
    set(h, 'HeaderFile', '');
    set(h, 'IsHeaderFileInstanceSpecific', false);
    set(h, 'CommentSource', 'Default');
    set(h, 'TypeComment', '');
    set(h, 'DeclareComment', '');
    set(h, 'DefineComment', '');
    set(h, 'CSCTypeAttributesClassName', '');
    set(h, 'TLCFileName', 'CompilerFlag.tlc');
    defs = [defs; h];

  case 'MemorySectionDefn'
    defs = [];

    h = Simulink.MemorySectionDefn;
    set(h, 'Name', 'MemConst');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'Comment', '/* Const memory section */');
    set(h, 'PragmaPerVar', false);
    set(h, 'PrePragma', '');
    set(h, 'PostPragma', '');
    set(h, 'IsConst', true);
    set(h, 'IsVolatile', false);
    set(h, 'Qualifier', '');
    defs = [defs; h];

    h = Simulink.MemorySectionDefn;
    set(h, 'Name', 'MemVolatile');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'Comment', '/* Volatile memory section */');
    set(h, 'PragmaPerVar', false);
    set(h, 'PrePragma', '');
    set(h, 'PostPragma', '');
    set(h, 'IsConst', false);
    set(h, 'IsVolatile', true);
    set(h, 'Qualifier', '');
    defs = [defs; h];

    h = Simulink.MemorySectionDefn;
    set(h, 'Name', 'MemConstVolatile');
    set(h, 'OwnerPackage', 'Simulink');
    set(h, 'Comment', '/* ConstVolatile memory section */');
    set(h, 'PragmaPerVar', false);
    set(h, 'PrePragma', '');
    set(h, 'PostPragma', '');
    set(h, 'IsConst', true);
    set(h, 'IsVolatile', true);
    set(h, 'Qualifier', '');
    defs = [defs; h];

  otherwise
    DAStudio.error('Simulink:dialog:CSCRegInvalidAction', action);
end  % switch action


%EOF