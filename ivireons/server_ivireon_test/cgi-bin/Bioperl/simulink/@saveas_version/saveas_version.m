
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $

classdef saveas_version
    properties(SetAccess = 'private')
        version;
        ver_info;
        ver_str;
    end
        
    properties(SetAccess = 'private',GetAccess = 'protected')
        ver_flags;
    end

    % wish this could be static but static variables can
    % only be scalar.
    properties(Constant, GetAccess = 'private')
            possible_strings = {...
                'SAVEAS_R12', 'SAVEAS_R12P1',...
                'SAVEAS_R13', 'SAVEAS_R13SP1', ...
                'SAVEAS_R14', 'SAVEAS_R14SP1', ...
                'SAVEAS_R14SP2', 'SAVEAS_R14SP3',...
                'SAVEAS_R2006A', 'SAVEAS_R2006B',...
                'SAVEAS_R2007A', 'SAVEAS_R2007B',...
                'SAVEAS_R2008A', 'SAVEAS_R2008B',...
                'SAVEAS_R2009A', 'SAVEAS_R2009B',...
                'SAVEAS_R2010A', 'SAVEAS_R2010B'};        
            
            possible_ver_info = {...
                'R12', 'R12.1',...
                'R13', 'R13 (SP1)', ...
                'R14', 'R14 (SP1)',...
                'R14 (SP2)', 'R14 (SP3)',...
                'R2006A', 'R2006B',...
                'R2007A', 'R2007B',...
                'R2008A', 'R2008B',...
                'R2009A', 'R2009B',...
                'R2010A', 'R2010B'};
            
            possible_ver_str = {...
                '4.0',  '4.1',...  %R12
                '5.0',  '5.1',...  %R13
                '6.0',  '6.1',...  %R14
                '6.2',  '6.3',...
                '6.4',  '6.5',...  %R2006
                '6.6',  '7.0',...  %R2007
                '7.1',  '7.2',...  %R2008
                '7.3',  '7.4',...  %R2009
                '7.5',  '7.5'};  %versions beyond the current version
                         %set to the current version number
    end            
    
    properties(Constant)
            r12        = 1;
            r12p1      = 2;
            r13        = 3;
            r13sp1     = 4;
            r14        = 5;
            r14sp1     = 6;
            r14sp2     = 7;
            r14sp3     = 8;
            r2006a     = 9;
            r2006b     = 10;
            r2007a     = 11;
            r2007b     = 12;
            r2008a     = 13;
            r2008b     = 14;
            r2009a     = 15;
            r2009b     = 16;
            r2010a     = 17;
            r2010b     = 18;
    end

    methods (Static)
        function x = getVersionStrings
            x = saveas_version.possible_strings(saveas_version.r14:saveas_version.r2010a);
        end
        
        function x = getVersionStringsGte(ver)
            flag = strcmp(ver,saveas_version.possible_strings);
            idx = find(flag);
            if ~isempty(idx)
                x = saveas_version.possible_strings(idx:saveas_version.r2009b);
            else
                DAStudio.error('Simulink:utility:slSaveAsBadVersion',ver);
            end
            
        end
        
        function x = versionInfoFromNumber(ver)
            x = saveas_version.versionInfoFromStr(sprintf('%1.1f',ver));
        end
        
        function x = versionInfoFromStr(verstr)
            flag = strcmp(verstr,saveas_version.possible_ver_str);
            idx = find(flag);
            if ~isempty(idx)
                % sometimes the release has moved on but the version string
                % has not yet been set.
                if (length(idx) > 1)
                    idx = idx(1);
                end
                x = saveas_version.possible_ver_info{idx};
            else
                DAStudio.error('Simulink:utility:slSaveAsBadVersion',verstr);
            end
            
        end
        
        function b = isValidVersion(ver)
            flag = strcmp(ver,saveas_version.getVersionStrings());
            b = any(flag);
        end
    end
    
    methods
        function obj = saveas_version(x)
            if ischar(x)
                obj.version = x;
            else
                DAStudio.error('Simulink:utility:slSaveAsBadVersion','')
            end
            obj.ver_flags = strcmp(obj.version,obj.possible_strings);
            obj.ver_flags(saveas_version.r12:saveas_version.r13sp1) = 0;
            if sum(obj.ver_flags) ~= 1
                DAStudio.error('Simulink:utility:slSaveAsBadVersion',x)
            end
            obj.ver_info = obj.possible_ver_info{obj.ver_flags};
            obj.ver_str  = obj.possible_ver_str{obj.ver_flags};
        end
        
        function x = isValid(obj)
            x = any(obj.ver_flags);
        end
        
        function x = isInVersionSet(obj, begin, last)
            x = any(obj.ver_flags(begin:last));
        end
        
        % if obj1 is greater than (later than) obj2
        function x = gt(obj1, obj2)
            [~, idx] = max(obj2.ver_flags);
            x = any(obj1.ver_flags(idx+1:end));
        end
        
        % individual versions
        function x = isR12(obj)
            x = any(obj.ver_flags(obj.r12));
        end
        function x = isR12p1(obj)
            x = any(obj.ver_flags(obj.r12p1));
        end
        function x = isR13(obj)
            x = any(obj.ver_flags(obj.r13));
        end
        function x = isR13sp1(obj)
            x = any(obj.ver_flags(obj.r13sp1));
        end
        function x = isR14(obj)
            x = any(obj.ver_flags(obj.r14));
        end
        function x = isR14sp1(obj)
            x = any(obj.ver_flags(obj.r14sp1));
        end
        function x = isR14sp2(obj)
            x = any(obj.ver_flags(obj.r14sp2));
        end
        function x = isR14sp3(obj)
            x = any(obj.ver_flags(obj.r14sp3));
        end
        function x = isR2006a(obj)
            x = any(obj.ver_flags(obj.r2006a));
        end
        function x = isR2006b(obj)
            x = any(obj.ver_flags(obj.r2006b));
        end
        function x = isR2007a(obj)
            x = any(obj.ver_flags(obj.r2007a));
        end
        function x = isR2007b(obj)
            x = any(obj.ver_flags(obj.r2007b));
        end
        function x = isR2008a(obj)
            x = any(obj.ver_flags(obj.r2008a));
        end
        function x = isR2008b(obj)
            x = any(obj.ver_flags(obj.r2008b));
        end
        function x = isR2009a(obj)
            x = any(obj.ver_flags(obj.r2009a));
        end
        function x = isR2009b(obj)
            x = any(obj.ver_flags(obj.r2009b));
        end
        function x = isR2010a(obj)
            x = any(obj.ver_flags(obj.r2010a));
        end
        function x = isR2010b(obj)
            x = any(obj.ver_flags(obj.r2010b));
        end
        
        % groups of versions
        function x = isInR12(obj)
            x = any(obj.ver_flags(obj.r12:obj.r12p1));
        end
        function x = isInR13(obj)
            x = any(obj.ver_flags(obj.r13:obj.r13sp1));
        end
        function x = isInR12OrR13(obj)
            x = any(obj.ver_flags(obj.r12:obj.r13sp1));
        end
        function x = isInR14(obj)
            x = any(obj.ver_flags(obj.r14:obj.r14sp3));
        end
        function x = isInR2006(obj)
            x = any(obj.ver_flags(obj.r2006a:obj.r2006b));
        end
        function x = isInR2007(obj)
            x = any(obj.ver_flags(obj.r2007a:obj.r2007b));
        end
        function x = isInR2008(obj)
            x = any(obj.ver_flags(obj.r2008a:obj.r2008b));
        end
        function x = isInR2009(obj)
            x = any(obj.ver_flags(obj.r2009a:obj.r2009b));
        end
        
        % given version or later
        function x = isR12OrLater(obj)
            x = any(obj.ver_flags(obj.r12:end));
        end
        function x = isR13OrLater(obj)
            x = any(obj.ver_flags(obj.r13:end));
        end
        function x = isR14OrLater(obj)
            x = any(obj.ver_flags(obj.r14:end));
        end
        function x = isR2006aOrLater(obj)
            x = any(obj.ver_flags(obj.r2006a:end));
        end
        
        % given version or earlier
        function x = isR2010bOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2010b));
        end
        function x = isR2010aOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2010a));
        end
        function x = isR2009bOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2009b));
        end
        function x = isR2009aOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2009a));
        end
        function x = isR2008bOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2008b));
        end
        function x = isR2008aOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2008a));
        end
        function x = isR2007bOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2007b));
        end
        function x = isR2007aOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2007a));
        end
        function x = isR2006bOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2006b));
        end
        function x = isR2006aOrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r2006a));
        end
        function x = isR14sp3OrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r14sp3));
        end
        function x = isR14sp2OrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r14sp2));
        end
        function x = isR14sp1OrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r14sp1));
        end
        function x = isR14OrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r14));
        end
        function x = isR13sp1OrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r13sp1));
        end
        function x = isR13OrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r13));
        end
        function x = isR12p1OrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r12p1));
        end
        function x = isR12OrEarlier(obj)
            x = any(obj.ver_flags(1:obj.r12));
        end
        
        % before mentioned version
        function x = isBeforeR2007a(obj)
            x = any(obj.ver_flags(1:obj.r2006b));
        end
        function x = isBeforeR2006b(obj)
            x = any(obj.ver_flags(1:obj.r2006a));
        end
        function x = isBeforeR2006a(obj)
            x = any(obj.ver_flags(1:obj.r14sp3));
        end
        function x = isBeforeR14sp3(obj)
            x = any(obj.ver_flags(1:obj.r14sp2));
        end
        function x = isBeforeR14sp2(obj)
            x = any(obj.ver_flags(1:obj.r14sp1));
        end
        function x = isBeforeR14sp1(obj)
            x = any(obj.ver_flags(1:obj.r14));
        end
        function x = isBeforeR14(obj)
            x = any(obj.ver_flags(1:obj.r13sp1));
        end
        function x = isBeforeR13sp1(obj)
            x = any(obj.ver_flags(1:obj.r13));
        end
        function x = isBeforeR13(obj)
            x = any(obj.ver_flags(1:obj.r12p1));
        end
        function x = isBeforeR12p1(obj)
            x = any(obj.ver_flags(1:obj.r12));
        end
    end
end
