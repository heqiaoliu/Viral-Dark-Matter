function unix2dos(file_in)
% simple utility for doing UNIX2ODS in MATLAB
% needed for PLC stuff

str = file2str(file_in);
str = unix2dos_local(str);
str2file(str,file_in);

function str = unix2dos_local(str)
% simple utility for doing UNIX2ODS in MATLAB
% needed for PLC stuff

str = regexprep(str,'\r','');
str = regexprep(str,'\n','\r\n');
