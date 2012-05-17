function CustomRTWInfoObject = createCustomRTWInfoObject(userPkgName, paramOrSignal)
%CREATECUSTOMRTWINFOOBJECT  Create RTWInfo object.
%  CREATECUSTOMRTWINFOOBJECT(USERPKGNAME, PARAMORSIGNAL) Creates RTWInfo object 
%  for subclasses of Simulink.Data that have their own local set of custom storage classes.
%
%  Input arguments:
%  - USERPKGNAME:   Name of package containing Parameter/Signal class.
%                   This package should also contain the csc_registration file to
%                   define the custom storage classes for these data classes.
%  - PARAMORSIGNAL: String to identify the type of data class.
%                   ('Parameter' OR 'Signal')

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/13 18:28:39 $ 



% This function creates an RTWInfo object (subclass from Simulink.CustomRTWInfo)
% for subclasses of Simulink.Data in the specified package.
%
% NOTE:
% - The RTWInfo object must be a UDD object because the RTWInfo property is a UDD
%   property (defined in Simulink.Data). All of our internal code for interacting
%   with storage classes and custom storage classes expects this to be a UDD object.
%
%- This function is called from both UDD and MCOS subclasses of Simulink.Data to
%   support custom storage classes for UDD/MCOS-based Simulink data classes.

% Check that user pkgName is not empty and is not Simulink.
assert(~isempty(userPkgName));
assert(~strcmp(userPkgName, 'Simulink'));

% Check if the CSC Registration file exists in the user package.
cscregfile = processcsc('GetCSCRegFile', userPkgName);
if(isempty(cscregfile))
    DAStudio.error('Simulink:dialog:CSCUINoCSCReg', userPkgName); 
end

% Get / create package to hold RTWInfo classes
rtwInfoPkgName = 'SimulinkCSC';
hRTWInfoPackage = findpackage(rtwInfoPkgName);

if isempty(hRTWInfoPackage)
    hRTWInfoPackage = schema.package(rtwInfoPkgName);
    if isempty(hRTWInfoPackage)
       DAStudio.error('Simulink:dialog:CSCDefnCustomAttribClassCreatePackage', rtwInfoPkgName);
    end 
end

className = ['CustomRTWInfo_' userPkgName '_' paramOrSignal];
if isempty(findclass(hRTWInfoPackage, className))
    
    % Create Enum type for CSCs
    enumTypeName = local_createUniqueEnum(userPkgName, paramOrSignal);
    
    % Create a user package CustomRTWInfo class
    %%%% Get handles of associated packages and classes
    hDeriveFromPackage = findpackage('Simulink');
    hDeriveFromClass   = findclass(hDeriveFromPackage, 'CustomRTWInfo');
    
    %%%% Construct class
    hThisRTWInfoClass = schema.class(hRTWInfoPackage, className, hDeriveFromClass);
    hThisRTWInfoClass.Handle = hDeriveFromClass.Handle;

    %%%% Add properties to this class
    schema.prop(hThisRTWInfoClass, 'CustomStorageClass', enumTypeName);
        
    %%%% Move CustomAttributes property after CustomStorageClass
    schema.prop(hThisRTWInfoClass, 'CustomAttributes', 'Simulink.BaseCSCAttributes');
    
    %%%% Add property to store original package name
    hThisProp = schema.prop(hThisRTWInfoClass, 'CSCPackageName', 'string');
    hThisProp.FactoryValue = userPkgName;
    hThisProp.Visible = 'off';
    hThisProp.AccessFlags.PublicSet  = 'off';
    hThisProp.AccessFlags.Copy       = 'off';
        
    %%%% Create CustomStorageClass listeners
    createcsclisteners(hThisRTWInfoClass);
end

% Instantiate the RTWInfo class
CustomRTWInfoObject = feval([rtwInfoPkgName '.' className]);

% Call CustomStorageClassListener
CustomRTWInfoObject.CustomStorageClassListener;

% =============================================================================
%  SUBFUNCTIONS:
% =============================================================================

function enumTypeName = local_createUniqueEnum(userPkgName, paramOrSignal)
% This code creates an enum type with a unique name every time 
% Custom RTWInfo class is created.

baseEnumTypeName = ['CSCList_for_' userPkgName '_' paramOrSignal];
enumTypeName = baseEnumTypeName;
suffix = 1;

% Keep increasing suffix number until enum is not found.
while (~isempty(findtype(enumTypeName)))
    enumTypeName = [baseEnumTypeName, num2str(suffix)];
    suffix = suffix+1;
end

% Create unique enum
cscList = processcsc(['GetNamesFor' paramOrSignal], userPkgName);
schema.EnumType(enumTypeName, cscList); 

%EOF
