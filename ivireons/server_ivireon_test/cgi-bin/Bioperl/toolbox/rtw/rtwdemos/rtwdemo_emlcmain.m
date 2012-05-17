function rc = main %#ok file name is rtwdemo_emlcmain
%#eml
imageSize = uint32(512*512);
fid = eml.opaque('FILE*','NULL');
fileName = cstring('rtwdemo_maggie.bin');

% Read the original image
filePerm = cstring('r+b');
fid = eml.ceval('fopen',eml.rref(fileName),eml.rref(filePerm));
originalImage = uint8(zeros(512,512));
eml.ceval('fread',eml.wref(originalImage),uint32(1),imageSize,fid);

% Detect edges
threshHold = 75;
edgeImage = rtwdemo_emlcsobel(originalImage, threshHold);

% Write new image
eml.ceval('rewind',fid);
eml.ceval('fwrite',eml.rref(edgeImage),uint32(1),imageSize,fid);
eml.ceval('fclose',fid);

rc = int32(0);

% Convert char array to c-string
function y = cstring(u)
y = [u 0]; 
