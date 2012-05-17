function p4checkin(fileNames, comment, lock)
tmpfile = 'tmpp4submit';

%p4 info  
%parse output for client and user
[infostatus, inforesult] = system('p4 info'); 
if (infostatus == 1)
    error(inforesult);
end;

pos = strfind(inforesult, 'User name: ');
pos2 = strfind(inforesult, sprintf('\n'));
user = inforesult(pos + length('User name: ') : pos2);

pos = strfind(inforesult, 'Client name: ');
substring = inforesult(pos:end);
pos2 = strfind(substring, sprintf('\n'));
client = substring(length('Client name: ') : pos2);

%p4 -ztag where fileNames  
% we'll parse output for depot File list
command = sprintf('p4 -ztag where %s', fileNames);
[wherestatus, whereresult] = system(command);
if (wherestatus == 1)
   error(whereresult);
end;

% Create submit file
fid = fopen(tmpfile, 'w');
fprintf(fid, 'Change: new \nClient: %sUser: %sStatus: new\nDescription: \n   %s \n', client, user, comment);
fprintf(fid, 'Files:\n');
pos3 = strfind(whereresult, 'depotFile');
% parse output for depot File list
for i= 1:length(pos3)
    substring = whereresult(pos3(i):end);
    pos4 = strfind(substring, sprintf('\n'));
    fileName =substring(length('depotFile ') : pos4);
    fprintf(fid,  '%s \n', fileName);
end;
fclose(fid);
if (strcmpi(lock, 'on'))
    command = sprintf('cat %s | p4 submit -i -r', tmpfile);
else
    command = sprintf('cat %s | p4 submit -i', tmpfile);
end;
[a,rV] = system(command);
disp(rV);