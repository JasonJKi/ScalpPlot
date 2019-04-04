classdef LocationInfo < handle
    %LOCATIONINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xPos
        yPos
        theta
        radius
        tmpeloc
        channelLabels
        channelIndex
    end
    
    methods
        
        function this = LocationInfo(theta, radius, tmpeloc, labels, channelIndex)
            if nargin < 1
                return
            end
            [xPos, yPos, thetaDegrees] = this.convertToCartesian(theta, radius);
            setLocationInfo(this, xPos, yPos, thetaDegrees, radius, tmpeloc, labels, channelIndex)
        end
        
        function this = setCarteisianCoorPos(this, xPos, yPos)
            this.xPos = xPos;
            this.yPos = yPos;
        end
        
        function this = setPolarCoordPos(this, theta, radius, isRadian)
            if nargin < 4
                isRadian = false;
            end
            
            [xPos, yPos, theta] = this.convertToCartesian(theta, radius, isRadian);
            setCarteisianCoorPos(this, xPos, yPos);
            this.theta = theta;
            this.radius = radius;
        end
        
        function this = getLocationInfo(this)
        end
        
        function this = readLocationFile(this, locationFilepath)
         % Read location file for channel position relative to the scalp.
            [tmpeloc, labels, theta, radius, channelIndex] = readLocationFile(locationFilepath);
            
            % Transform the position from polar to cartesian coordinate.            
            [xPos, yPos, thetaDegrees] = this.convertToCartesian(theta, radius, true);
            
            setLocationInfo(this, xPos, yPos, thetaDegrees, radius, tmpeloc, labels, channelIndex);
        end
        
        function setLocationInfo(this, xPos, yPos, theta, radius, tmpeloc, labels, channelIndex)
            % Assign structure for location points
            this.theta = theta;
            this.radius = radius;
            this.xPos = xPos;
            this.yPos = yPos;
            if nargin > 4
                this.tmpeloc = tmpeloc;
                this.channelLabels = char(labels); % make a label string matrix
                this.channelIndex = channelIndex;
            end
        end
        
        function [xPos, yPos, radius, theta, tmpeloc, channelLabels, channelIndex] = ...
                getLocationValues(this)
            % Assign structure for location points
            xPos = this.xPos;
            yPos = this.yPos;
            theta = this.theta;
            radius = this.radius;
            tmpeloc = this.tmpeloc;
            channelLabels = this.channelLabels;
            channelIndex = this.channelIndex ;
        end
        
    end
    
    methods (Static)
        function [xPos, yPos, theta] = convertToCartesian(theta, radius, isRadian)
            % Convert degrees to radians.
            if isRadian
                theta = pi/180*theta;
            end
            % Transform electrode locations from polar to cartesian coordinate.
            [xPos, yPos] = pol2cart(theta, radius);
        end
    end
end

