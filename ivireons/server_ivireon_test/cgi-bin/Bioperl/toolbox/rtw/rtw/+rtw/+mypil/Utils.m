classdef (Hidden = true) Utils < handle
%UTILS provides general utility methods

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

    methods (Static = true)

        function Uncomment(fileName)

            fid = fopen(fileName);
            content = fread(fid,inf,'uchar');
            fclose(fid);
            content = char(content');
            
            % uncomment commented lines ending in %UNCOMMENT
            content = regexprep(content,'\n%([^\n]*%UNCOMMENT[^\n]*)','\n$1');
            
            % write the back out
            fid = fopen(fileName,'w+');
            fwrite(fid,content,'uchar');
            fclose(fid);
            
        end
    
        function UpdateClassName(fileName,oldClassName,newClassName)

            fid = fopen(fileName);
            content = fread(fid,inf,'uchar');
            fclose(fid);
            content = char(content');
            
            % replace oldClassNameStr with newClassName
            oldClassNameRegexp = strrep(oldClassName,'.','\.');
            content = regexprep(content, oldClassNameRegexp, newClassName);
            
            % write the back out
            fid = fopen(fileName,'w+');
            fwrite(fid,content,'uchar');
            fclose(fid);
            
        end
    end
end
