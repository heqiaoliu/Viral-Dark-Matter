function edgeImage = rtwdemo_emlcsobel(originalImage, threshHold) %#eml
% Sobel edge-detection
k = [1 2 1; 0 0 0; -1 -2 -1];
H = conv2(double(originalImage),k, 'same');
V = conv2(double(originalImage),k','same');
E = sqrt(H.*H + V.*V);
edgeImage = uint8((E < threshHold) * 255);
