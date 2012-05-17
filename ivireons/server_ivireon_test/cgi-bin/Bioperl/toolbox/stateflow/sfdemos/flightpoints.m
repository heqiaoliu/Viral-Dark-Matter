% pick points from 2D flight plan
%plot(0,0);
%axis([-2000, 2000, -2000 2000]);
%grid on;
%[fpX, fpY] = ginput(16);

%fpZ = 5000*ones(16, 1);
%fpZ(1) = 0;
%fpZ(1:4) = linspace(0, 4500, 4);
%fpZ(7:12) = linspace(5000, 500, 6);
%fpZ(12:15) = linspace(500, 1, 4);
%fpZ(16) = 0;

% flight plan
%stem3 (fpX, fpY, fpZ, 'DisplayName', 'fpX, fpY, fpZ'); figure(gcf)
%hold on
%fpXYZ = [fpX'; fpY'; fpZ'];
%fnplt(cscvn(fpXYZ),'r',2);
%pause;

% generate points for flight plan
%fpPTS = fnplt(cscvn(fpXYZ),'r',2);

% smooth out flight path data
fpPTS(1, :) = smooth(fpPTS(1, :));
fpPTS(2, :) = smooth(fpPTS(2, :));
fpPTS(3, :) = smooth(fpPTS(3, :));

% compute pitch and yaw angles
% convert to complex numbers for XY plane
fpXY = fpPTS(1, :) + i * fpPTS(2, :);
fpZ = fpPTS(3, :);

% compute yaw angle
fpYaw = unwrap([0, angle(fpXY(2:end) - fpXY(1:end-1)) + pi/2]);

% compute pitch angle
fpXYabs = abs(fpXY(2:end) - fpXY(1:end-1));
fpDelZ = fpZ(2:end) - fpZ(1:end-1);
fpPitch = [0, pi/2 - atan2(fpDelZ, fpXYabs)];
disp('Hit key to add to signal builder!');
pause;

signalbuilder([], 'CREATE', 0:length(fpZ)-1, {fpYaw; fpPTS(1, :); fpPTS(2, :); fpPTS(3, :); fpPitch}, {'Yaw', 'North', 'East', 'altitude', 'Pitch'});

% for k = 1:size(fpPTS, 2),
%     setfield(buranYaw, 'rotation', [0 0 1 fpYaw(k)]);
%     setfield(buranPitch, 'rotation', [1 0 0 fpPitch(k)]);
%     setfield(buranYaw, 'translation', fpPTS(:, k)');
%     pause(0.2);
% end
