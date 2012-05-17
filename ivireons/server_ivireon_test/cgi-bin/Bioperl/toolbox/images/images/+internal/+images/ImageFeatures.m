%ImageFeatures Image features object
%
%   An ImageFeatures object describes the locations and local image
%   structure around a set of interest points.
%
%   features = ImageFeatures(interestPoints, descriptors, extractMethod)
%   constructs an ImageFeatures object from the input arguments
%   interestPoints, descriptors, and extractMethod. The first input
%   argument, interestPoints, is an M-by-2 double matrix containing the X
%   and Y coordinates of the interest points found in an image. Interest
%   points are spatial locations of detected local image features image.
%   For instance, to find corners, you use the CORNER function to return
%   likely corner points, and these are your interest points. The second
%   input argument, descriptors, is an M-by-N matrix of descriptors (also
%   known as feature vectors). Each row of the descriptors matrix contains
%   the descriptor associated with the interest point at the same index.
%   The third input argument, extractMethod, is a string describing the
%   feature extraction algorithm used to obtain the descriptors.  Valid 
%   extractMethod values are 'Block' or 'ZScore'.
%
%   Object properties may not be modified after construction.
%
%   ImageFeatures properties:
%      InterestPoints - M-by-2 double matrix of interest points
%      Descriptors    - M-by-N matrix of descriptors associated with each 
%                       interest point
%      ExtractMethod  - Feature extraction method ('Block' or 'ZScore')

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/04 16:21:03 $
    
classdef ImageFeatures
    properties (SetAccess = 'private')
        % InterestPoints - M-by-2 double matrix of interest points. 
        %                  Interest points (also known as keypoints, 
        %                  feature points or corners) are spatial locations 
        %                  of detected local image features. 
        InterestPoints
        
        % Descriptors    - M-by-N double matrix of descriptors associated 
        %                  with each interest point. Note that descriptors 
        %                  are also known as feature vectors.
        Descriptors
        
        % ExtractMethod  - Feature extraction method.  Valid values are 
        %                  'Block' or 'ZScore'.
        ExtractMethod
    end
    
    methods
        function obj  = ImageFeatures(interestPoints, descriptors, extractMethod)
            obj.InterestPoints = interestPoints;
            obj.Descriptors = descriptors;
            obj.ExtractMethod = extractMethod;
        end
        
        function obj = set.InterestPoints(obj, interestPoints)
            validateattributes(interestPoints, {'numeric'}, {'2d','nonempty',...
                'nonsparse','nonnan','real'}, mfilename, 'interestPoints', 1);
            assert(size(interestPoints, 2) == 2, ...
                'Images:ImageFeatures:invalidInterestPointsMatrix', ...
                '''InterestPoints'' must be an M-by-2 matrix');
            obj.InterestPoints = interestPoints;
        end
        
        function obj  = set.Descriptors(obj, descriptors)
            validateattributes(descriptors, {'numeric'}, {'2d','nonempty', ...
                'nonsparse','real'}, mfilename, 'descriptors', 2);
            obj.Descriptors = descriptors;
        end
        
        function obj  = set.ExtractMethod(obj, extractMethod)
            validatestring(extractMethod, {'Block', 'ZScore'}, mfilename, ...
                'extractMethod', 3);
            obj.ExtractMethod = extractMethod;
        end
    end
end