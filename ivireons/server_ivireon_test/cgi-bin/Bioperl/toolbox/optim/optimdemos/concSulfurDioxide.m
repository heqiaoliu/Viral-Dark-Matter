function K = concSulfurDioxide(x, y, h, theta, U)
%CONCSULFURDIOXIDE Concentration of sulfur dioxide in the region
%
%   K = CONCSULFURDIOXIDE(X, Y, H, THETA, U) calculates the concentration
%   of Sulfur Dioxide at the single point (X, Y) on the ground, given the
%   chimney stack heights H, the wind direction THETA and the wind speed U. 
%
%   K = CONCSULFURDIOXIDE(XX, YY, H, THETA, U) performs the calculation for
%   each pair of ground points defined by the matrices XX and YY. Note that
%   XX and YY must have the same size. In addition THETA and U must be
%   scalar. This call is useful if XX and YY have been generated using
%   MESHGRID.
%   
%   K = CONCSULFURDIOXIDE(X, Y, H, TT, UU) performs the calculation for
%   each wind speed/direction pair defined by the matrices TT and UU. Note
%   that TT and UU must have the same size. In addition X and Y must be
%   scalar. This call is useful if TT and UU have been generated using
%   MESHGRID.
%
%   This file is required for the Air Pollution Fseminf Demo
%
%   See also AIRPOLLUTIONCON, UNCERTAINAIRPOLLUTIONCON, PLOTSULFURDIOXIDE,
%   PLOTSULFURDIOXIDEUNCERTAIN 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/08 18:46:21 $

% Get problem data
[xpos, ypos, nStacks, V, diam, Ts, Q, Te] = airPollutionProblemData;

% Calculate the concentration
if numel(x) > 1 && numel(y) > 1    
    % Matrices supplied for x and y, scalars for theta and U. 
    % The sulfur dioxide concentration, C, is returned as a
    % NROW-by-NCOL-by-NSTACKS matrix. NROW is the number of rows of x and
    % NCOL is the number of columns of y.     
    C = i_concOverXY(x, y, h, theta, U, xpos, ypos, Q, V, diam, Ts, Te, nStacks);
elseif numel(theta) > 1 && numel(U) > 1
    % Matrices supplied for theta and U, scalars for x and y.    
    % The sulfur dioxide concentration, C, is returned as a
    % NROW-by-NCOL-by-NSTACKS matrix. NROW is the number of rows of theta
    % and NCOL is the number of columns of U.     
    C = i_concOverThetaU(x, y, h, theta, U, xpos, ypos, Q, V, diam, Ts, Te, nStacks);
else
    % Assume that x, y, theta and U are scalar.
    % The sulfur dioxide concentration, C, is returned as a
    % 1-by-1-by-NSTACKS matrix. 
    C = i_concAtXYThetaU(x, y, h, theta, U, xpos, ypos, Q, V, diam, Ts, Te, nStacks);
end

% Total concentration is the sum of sulfur dioxide from each stack
K = sum(C, 3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function C = i_concOverXY(x, y, h, theta, U, xpos, ypos, Q, V, diam, Ts, Te, nStacks)

% The sulfur dioxide concentration from each chimney stack will be
% calculated at each point of an (x, y) grid. Determine the number of rows,
% nx, and columns, ny, of the (x, y) grid.
nx = size(x, 1);
ny = size(x, 2);

% Reshape and repmat variables so that we can perform a vectorized
% calculation of sulfur dioxide concentration at each (x, y) point for each
% chimney stack.
rxpos = i_reshapeAndRepmat(xpos, nx, ny, nStacks);
rypos = i_reshapeAndRepmat(ypos, nx, ny, nStacks);
rQ = i_reshapeAndRepmat(Q, nx, ny, nStacks);

% Repmat (x, y) grid for each chimney stack, again to allow vectorized
% calculation of sulfur dioxide.
rx = x(:, :, ones(1, nStacks));
ry = y(:, :, ones(1, nStacks));

% Plume height. Delta H paramenters (plume), Holland equation
dH = (V.*diam./U).*(1.5+2.68*diam.*(Ts-Te)./Ts);

% Transform x and y coordinates of stack
[X, Y] = i_transformXY(rx, ry, rxpos, rypos, theta);

% Standard deviations
[sigmaY, sigmaZ, sigmaZY] = i_calcStandardDeviations(X, nx, ny, nStacks);

% Concentration of gas
hPlusDh = h + dH;
hPlusDh = reshape(hPlusDh, 1, 1, nStacks);
hPlusDh = hPlusDh(ones(nx, 1), ones(ny, 1), :);
C = i_calcConc(hPlusDh, Y, sigmaY, sigmaZ, sigmaZY, U, rQ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function C = i_concOverThetaU(x, y, h, theta, U, xpos, ypos, Q, V, diam, Ts, Te, nStacks)

% The sulfur dioxide concentration from each chimney stack will be
% calculated at each point of a (theta, U) grid. Determine the number of
% rows, nt, and columns, nu, of the (theta, U) grid.
nt = size(theta, 1);
nu = size(theta, 2);

% Reshape and repmat variables so that we can perform a vectorized
% calculation of sulfur dioxide concentration at each (theta, U) point for
% each chimney stack.
rxpos = i_reshapeAndRepmat(xpos, nt, nu, nStacks);
rypos = i_reshapeAndRepmat(ypos, nt, nu, nStacks);
rh = i_reshapeAndRepmat(h, nt, nu, nStacks);
rQ = i_reshapeAndRepmat(Q, nt, nu, nStacks);
rTs = i_reshapeAndRepmat(Ts, nt, nu, nStacks);
rV = i_reshapeAndRepmat(V, nt, nu, nStacks);
rdiam = i_reshapeAndRepmat(diam, nt, nu, nStacks);

% Repmat (theta, U) grid for each chimney stack, again to allow vectorized
% calculation of sulfur dioxide.
rtheta = theta(:, :, ones(1, nStacks));
rU = U(:, :, ones(1, nStacks));

% Plume height. Delta H paramenters (plume), Holland equation
dH = (rV.*rdiam./rU).*(1.5+2.68*rdiam.*(rTs-Te)./rTs);

% Transform x and y coordinates of stack
[X, Y] = i_transformXY(x, y, rxpos, rypos, rtheta);

% Standard deviations
[sigmaY, sigmaZ, sigmaZY] = i_calcStandardDeviations(X, nt, nu, nStacks);

% Concentration of gas
hPlusDh = rh + dH;
C = i_calcConc(hPlusDh, Y, sigmaY, sigmaZ, sigmaZY, rU, rQ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function C = i_concAtXYThetaU(x, y, h, theta, U, xpos, ypos, Q, V, diam, Ts, Te, nStacks)

% Plume height. Delta H paramenters (plume), Holland equation
dH = (V.*diam./U).*(1.5+2.68*diam.*(Ts-Te)./Ts);

% Transform x and y coordinates of stack
[X, Y] = i_transformXY(x, y, xpos, ypos, theta);

% Standard deviations
[sigmaY, sigmaZ, sigmaZY] = i_calcStandardDeviations(X, nStacks, 1, 1);

% Concentration of gas
hPlusDh = h + dH;
C = i_calcConc(hPlusDh, Y, sigmaY, sigmaZ, sigmaZY, U, Q);
C = reshape(C, 1, 1, numel(C));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sigmaY, sigmaZ, sigmaZY] = i_calcStandardDeviations(X, nX, nY, nStacks)

% Mark grid points where X value is in a given range
Xle10 = X <= 10;
Xgt10le2K = ~Xle10 & X <= 2000;
Xgt2Kle10K = X > 2000 & X <= 10000;
Xgt10Kle100K = X > 10000 & X <= 100000;

% Calculate the standard deviation of plume concentration in the
% y-direction
sigmaY = ones(nX, nY, nStacks);
sigmaY(Xle10) = 0.9591;
sigmaY(Xgt10le2K) = 0.1136*X(Xgt10le2K).^0.9265;
sigmaY(Xgt2Kle10K ) = 0.1385*X(Xgt2Kle10K).^0.9015;
sigmaY(Xgt10Kle100K) = 0.2030*X(Xgt10Kle100K).^0.8600;

% Mark grid points where X value is in a given range
Xgt10le200 = ~Xle10 & X <= 200;
Xgt200le1K = X > 200 & X <= 1000;
Xgt1Kle5K = X > 1000 & X <= 5000;
Xgt5Kle100K = X > 5000 & X <= 100000;

% Calculate the product of standard deviations of plume concentration in
% the y and z-directions
sigmaZY = ones(nX, nY, nStacks);
sigmaZY(Xle10) = 0.07925;
sigmaZY(Xgt10le200) = 4.828E-5*(log(X(Xgt10le200))).^8.8766;
sigmaZY(Xgt200le1K) = 3.108E-6*(log(X(Xgt200le1K))).^10.5295;
sigmaZY(Xgt1Kle5K) = 1.808E-7*(log(X(Xgt1Kle5K))).^11.9998;
sigmaZY(Xgt5Kle100K) = 1.892E-9*(log(X(Xgt5Kle100K))).^14.1284;

% Calculate the standard deviation of plume concentration in the
% z-direction
sigmaZ = sigmaZY./sigmaY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, Y] = i_transformXY(x, y, xpos, ypos, theta)

% Transform (x, y) coordinates so that the X axis is aligned with the wind
% direction
xdist = x - xpos;
ydist = y - ypos;
X = xdist.*cos(theta) - ydist.*sin(theta);
Y = xdist.*sin(theta) + ydist.*cos(theta);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function C = i_calcConc(hPlusDh, Y, sigmaY, sigmaZ, sigmaZY, U, Q)

% Perform vectorized calculation of sulfur dioxide concentration
eY = (Y./sigmaY).^2;
eZ = (hPlusDh./sigmaZ).^2;
sU = (sigmaZY.*U);
C = (0.8/pi)*Q.*(1./sU).*exp( -0.5*( eY + eZ ));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rColVec = i_reshapeAndRepmat(colVec, nRow, nCol, nStacks)

% Reshape the nStacks-by-1 column vector to a 1-by-1-by-nStacks matrix
colVec = reshape(colVec, 1, 1, nStacks);

% Repmat the 1-by-1-by-nStacks matrix to form a nRow-by-nCol-by-nStacks
% matrix
rColVec = colVec(ones(nRow, 1), ones(nCol, 1), :);
