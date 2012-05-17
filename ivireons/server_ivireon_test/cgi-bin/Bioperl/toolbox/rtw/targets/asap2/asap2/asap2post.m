function asap2post(ASAP2File, MAPFile)
% ASAP2POST Post-processing of ASAP2 file.
%
%   Operations performed:
%   - Replace ECU_Address placeholders with addresses from appropriate
%     MAP file
%
%   Syntax:
%   ASAP2POST(ASAP2File, MAPFile)
%
%   Inputs:
%   - ASAP2File: ASAP2 file.
%   - MAPFile:   Corresponding Linker MAP file
%
%   ECU_Address Placeholder Replacement:
%   --------------------------------------
%   - Calls "getSymbolTable1" to get the symbol table (constructed from a      
%     linker map file).
%   - Parses through the ASAP2 file and replaces ECU_Address placeholder
%     with actual memory address (from symbol table).
%   - The default MATLAB subfunction provided expects the following:
%     - ECU_Address placeholder in ASAP2 file: 
%       0x0000 /* @ECU_Address@varName@ */
%     - MAP file format (space OR tab delimited):
%       ----------------------------------------
%       varName(column1)  ECU_Address(column2)
%       ----------------------------------------
%       a                 0xFFF0
%       b                 0xFFF1
%       ...
%
%   MAP files vary from compiler to compiler. 
%   To use the provided MATLAB subfunction with your compiler, either:
%   - Modify the existing MATLAB subfunction to suite your MAP file format
%   (or use any of the example subfunctions provided that correspond to
%   your file format) 
%   OR
%   - Reformat your MAP file to match the format described above.

%   Copyright 1994-2010 The MathWorks, Inc.
%   $Revision: 1.3.2.4 $
%   $Date: 2010/04/05 22:30:37 $

if nargin~=2
    DAStudio.Error('RTW:asap2:invalidInputParam',mfilename);
end

addrPrefix = '0x0000 \/\* @ECU_Address@';
addrSuffix = '@ \*\/';

% Extract contents of ASAP2 file
if exist(ASAP2File,'file')
    ASAP2FileString = fileread(ASAP2File);
else
    DAStudio.error('RTW:asap2:UnableFindFile',ASAP2File);
end

% Extract contents of MAP file
if exist(MAPFile,'file')
    MAPFileString = fileread(MAPFile);
else
    DAStudio.error('RTW:asap2:UnableFindFile',MAPFileName);
end

% Create symbol table from symbol names and addresses extracted from
% MAP file
MAPFileHash = getSymbolTable1(MAPFileString) ;     %#ok<NASGU>

% Identify placeholder strings and replace them dynamically with symbol
% values in hash table.
% In this regular expression, the token (\w+) will be the symbol name.
% This symbol name is specified (using $1) in the dynamic regular
% expression (${....})
newASAP2FileString = regexprep(ASAP2FileString,...
    [addrPrefix '(\w+)' addrSuffix], '${MAPFileHash($1)}');

% Write new content to original ASAP2 file
fid = fopen(ASAP2File, 'w');
fprintf(fid,'%s',newASAP2FileString);
fclose(fid);


% =========================================================================
% SUBFUNCTIONS
% =========================================================================    
    
 function MAPFileHash = getSymbolTable1(MAPFileString)   
 % GETSYMBOLTABLE1: Extract symbol names and symbol values from
 % the linker MAP file and store them into a hash table    

 % The following regular expression assumes the following MAP file
 % format (space OR tab delimited):
 %       ----------------------------------------
 %       varName(column1)  ECU_Address(column2)
 %       ----------------------------------------
 %       a                 0xFFF0
 %       b                 0xFFF1
 %       ...
     pairs = regexp(MAPFileString, '\n\s*(\S+)\s+0x([0-9a-fA-F]+)\W', ...
                                   'tokens');
     
     % Store symbol names and corresponding symbol values into a hash table
     MAPFileHash = containers.Map;
     for i = 1:length(pairs)
         MAPFileHash(pairs{i}{1}) = pairs{i}{2};
     end     

%% Sub-functions for sample linker map formats     
%     
% function MAPFileHash = getSymbolTable2(MAPFileString)
% % GETSYMBOLTABLE2: Extract symbol names and symbol values from
% % the linker MAP file and store them into a hash table
% % 
% %   Format:
% % 
% %       -------------------------------------------------------------
% %       someText(column1)  ECU_Address(column2)  varName(column3)
% %       -------------------------------------------------------------
% %       .data              FFF0                    a
% %       .data              FFF1                    b
% %       ...
% % 
%     pairs = regexp(MAPFileString, '\n\s*\S+\s+([0-9a-fA-F]+)\W+(\S+)',...
%         'tokens');
%     
%     % Store symbol names and corresponding symbol values into a hash table
%     MAPFileHash = containers.Map;
%     for i = 1:length(pairs)
%         MAPFileHash(pairs{i}{2}) = pairs{i}{1};
%     end
% 
% function MAPFileHash = getSymbolTable3(MAPFileString)
% % GETSYMBOLTABLE3: Extract symbol names and symbol values from
% % the linker MAP file and store them into a hash table
% %
% %   Format:
% %
% %      -------------------------------------------------------------
% %       varName(column1)  ECU_Address(column2)
% %      -------------------------------------------------------------
% %       | a               | 0xFFF0 |
% %       | b               | 0xFFF1 |
% %       ...
% %
%     pairs = regexp(MAPFileString, ...
%         '\n\s*\|\s+(\S+)\s+\|\s+(0x[0-9a-fA-F]+)\W', 'tokens');
%     
%     % Store symbol names and corresponding symbol values into a hash table
%     MAPFileHash = containers.Map;
%     for i = 1:length(pairs)
%         MAPFileHash(pairs{i}{1}) = pairs{i}{2};
%     end
% 
%  function MAPFileHash = getSymbolTable4(MAPFileString)
%  % GETSYMBOLTABLE4: Extract symbol names and symbol values from
%  % the linker MAP file and store them into a hash table
%  %
%  %   Format:
%  %
%  %      -------------------------------------------------------------
%  %       varName(column1)  ECU_Address(column2)
%  %      -------------------------------------------------------------
%  %       <SYMBOL name='a' address='0xFFF0'  ...
%  %       <SYMBOL name='b' address='0xFFF1'  ...
%  %       ...
%  %
%      pairs = regexp(MAPFileString, ...
%          '\n\s*<SYMBOL\sname=''(\S+)''\s+address=''0x([0-9a-fA-F]+)''\W', ...
%          'tokens');
% 
%      % Store symbol names and corresponding symbol values into a hash table
%      MAPFileHash = containers.Map;
%      for i = 1:length(pairs)
%          MAPFileHash(pairs{i}{1}) = pairs{i}{2};
%      end
     
% EOF
