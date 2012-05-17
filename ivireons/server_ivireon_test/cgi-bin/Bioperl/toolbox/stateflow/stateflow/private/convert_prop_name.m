% Convert fieldName to sf internal API fieldname or ConfigSet API fieldname
% useSF: true  output sf internal API fieldname
%        false output ConfigSet API fieldname
%
% fieldName:   intput fieldName
%
% isRTW: true    output ConfigSet API fieldname for RTW target
%        false   output ConfigSet API fieldname for sfun target
%        useless when useSF is true
%
% $Revision: 1.1.6.5 $
% Copyright 2008-2009 The MathWorks, Inc.
%
function [csObjName, resultType] = convert_prop_name(useSF, fieldName, isRTW)

  csObjName  = [];
  resultType = [];

  switch (lower(fieldName))
    case {'applytoalllibs', '.applytoalllibs', 'target.applytoalllibs'}
      if useSF
        csObjName = 'target.applyToAllLibs';
      else
        error('Stateflow:UnexpectedError','Obsolete field name.');
      end

    case {'document', '.document', 'target.document'}
      if useSF
        csObjName = 'target.document';
      else
        error('Stateflow:UnexpectedError','Obsolete field name.');
      end

    case {'codegendirectory', '.codegendirectory', 'target.codegendirectory'}
      if useSF
        csObjName = 'target.codegenDirectory';
      else
        error('Stateflow:UnexpectedError','Obsolete field name.');
      end

    case {'uselocalcustomcodesettings', '.uselocalcustomcodesettings', 'target.uselocalcustomcodesettings'}
      if useSF
        csObjName = 'target.useLocalCustomCodeSettings';
      else
         if isRTW
           csObjName = 'RTWUseLocalCustomCode';
         else
           csObjName = 'SimUseLocalCustomCode';
         end
         resultType = 'bool';
      end

    case {'customcode', '.customcode', 'target.customcode', ...
          'customheadercode', '.customheadercode', 'target.customheadercode'}
      if useSF
        csObjName  = 'target.customCode';
      else
        if isRTW
          csObjName  = 'CustomHeaderCode';
        else
          csObjName  = 'SimCustomHeaderCode';
        end
        resultType = 'string';
      end

    case {'customsourcecode', '.customsourcecode', 'target.customsourcecode'}
      if useSF
          %error('Stateflow:UnexpectedError','Unknown field name.');
          csObjName = '';
          resultType = '';
      else
        if isRTW
          csObjName  = 'CustomSourceCode';
        else
          csObjName  = 'SimCustomSourceCode';
        end
        resultType = 'string';
      end

    case {'custominitializer', '.custominitializer', 'target.custominitializer'}
      if useSF
        csObjName  = 'target.customInitializer';
      else
        if isRTW
          csObjName  = 'CustomInitializer';
        else
          csObjName  = 'SimCustomInitializer';
        end
        resultType = 'string';
      end

    case {'customterminator', '.customterminator', 'target.customterminator'}
      if useSF
        csObjName  = 'target.customTerminator';
      else
        if isRTW
          csObjName  = 'CustomTerminator';
        else
          csObjName  = 'SimCustomTerminator';
        end
        resultType = 'string';
      end

    case {'description', '.description', 'target.description'}
      if useSF
        csObjName  = 'target.description';
      else
        csObjName  = 'Description';
        resultType = 'string';
      end

    case {'reservednames', '.reservednames', 'target.reservednames'}
      if useSF
        csObjName  = 'target.reservedNames';
      else
        if isRTW
          csObjName  = 'ReservedNames';
        else
          csObjName  = 'SimReservedNames';
        end
        resultType = 'string';
      end

    case {'userincludedirs', '.userincludedirs', 'target.userincludedirs'}
      if useSF
        csObjName  = 'target.userIncludeDirs';
      else
        if isRTW
          csObjName  = 'CustomInclude';
        else
          csObjName  = 'SimUserIncludeDirs';
        end
        resultType = 'string';
      end

    case {'userlibraries', '.userlibraries', 'target.userlibraries'}
      if useSF
        csObjName  = 'target.userLibraries';
      else
        if isRTW
          csObjName  = 'CustomLibrary';
        else
          csObjName  = 'SimUserLibraries';
        end
        resultType = 'string';
      end

    case {'usersources' ,'.usersources', 'target.usersources'}
      if useSF
        csObjName  = 'target.userSources';
      else
        if isRTW
          csObjName  = 'CustomSource';
        else
          csObjName  = 'SimUserSources';
        end
        resultType = 'string';
      end

    case {'codeflags.debug', '.codeflags.debug', 'target.codeflags.debug'}
      if useSF || isRTW
        error('Stateflow:UnexpectedError','Unknown field name.');
      else
        csObjName  = 'SFSimEnableDebug';
        resultType = 'bool';
      end

    case {'codeflags.overflow', '.codeflags.overflow', 'target.codeflags.overflow'}
      if useSF || isRTW
        error('Stateflow:UnexpectedError','Unknown field name.');
      else
        csObjName  = 'SFSimOverflowDetection';
        resultType = 'bool';
      end

    case {'codeflags.echo', '.codeflags.echo', 'target.codeflags.echo'}
      if useSF || isRTW
        error('Stateflow:UnexpectedError','Unknown field name.');
      else
        csObjName  = 'SFSimEcho';
        resultType = 'bool';
      end

    case {'codeflags.blas', '.codeflags.blas', 'target.codeflags.blas'}
      if useSF || isRTW
        error('Stateflow:UnexpectedError','Unknown field name.');
      else
        csObjName  = 'SimBlas';
        resultType = 'bool';
      end

    case {'codeflags.integrity', '.codeflags.integrity', 'target.codeflags.integrity'}
      if useSF || isRTW
        error('Stateflow:UnexpectedError','Unknown field name.');
      else
        csObjName  = 'SimIntegrity';
        resultType = 'bool';
      end

    case {'codeflags.extrinsic', '.codeflags.extrinsic', 'target.codeflags.extrinsic'}
      if useSF || isRTW
        error('Stateflow:UnexpectedError','Unknown field name.');
      else
        csObjName  = 'SimExtrinsic';
        resultType = 'bool';
      end

    case {'codeflags.ctrlc', '.codeflags.ctrlc', 'target.codeflags.ctrlc'}
      if useSF || isRTW
        error('Stateflow:UnexpectedError','Unknown field name.');
      else
        csObjName  = 'SimCtrlC';
        resultType = 'bool';
      end

    case {'codeflags', '.codeflags', 'target.codeflags'}
      if useSF
        csObjName  = 'target.codeFlags';
      else
        csObjName  = 'codeflags';
        resultType = 'string';
      end

    otherwise
      if useSF
        csObjName = fieldName;
      else
        error('Stateflow:UnexpectedError','Unknown field name.');
      end
  end
