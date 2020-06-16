classdef LocationInfo < handle
    %LOCATIONINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x_pos
        y_pos
        theta
        radius
        tmp_loc
        channel_labels
        channel_index
    end
    
    methods
        
        function this = LocationInfo(theta, radius, tmp_loc, labels, channel_index)
            if nargin < 1
                return
            end
            [x_pos, y_pos, theta_degrees] = this.convertToCartesian(theta, radius);
            setLocationInfo(this, x_pos, y_pos, theta_degrees, radius, tmp_loc, labels, channel_index)
        end
        
        function this = setCarteisianCoorPos(this, x_pos, y_pos)
            this.x_pos = x_pos;
            this.y_pos = y_pos;
        end
        
        function this = setPolarCoordPos(this, theta, radius, isRadian)
            if nargin < 4
                isRadian = false;
            end
            
            [x_pos, y_pos, theta] = this.convertToCartesian(theta, radius, isRadian);
            setCarteisianCoorPos(this, x_pos, y_pos);
            this.theta = theta;
            this.radius = radius;
        end
        
        function this = getLocationInfo(this)
        end
        
        function this = readLocationFile(this, locationFilepath)
         % Read location file for channel position relative to the scalp.
            [tmp_loc, labels, theta, radius, channel_index] = readlocs(locationFilepath);
            
            % Transform the position from polar to cartesian coordinate.            
            [x_pos, y_pos, theta_degrees] = this.convertToCartesian(theta, radius, true);
            
            setLocationInfo(this, x_pos, y_pos, theta_degrees, radius, tmp_loc, labels, channel_index);
        end
        
        function setLocationInfo(this, x_pos, y_pos, theta, radius, tmp_loc, labels, channel_index)
            % Assign structure for location points
            this.theta = theta;
            this.radius = radius;
            this.x_pos = x_pos;
            this.y_pos = y_pos;
            if nargin > 4
                this.tmp_loc = tmp_loc;
                this.channel_labels = char(labels); % make a label string matrix
                this.channel_index = channel_index;
            end
        end
        
        function [x_pos, y_pos, radius, theta, tmp_loc, channel_labels, channel_index] = ...
                getLocationValues(this)
            % Assign structure for location points
            x_pos = this.x_pos;
            y_pos = this.y_pos;
            theta = this.theta;
            radius = this.radius;
            tmp_loc = this.tmp_loc;
            channel_labels = this.channel_labels;
            channel_index = this.channel_index ;
        end
        
    end
    
    methods (Static)
        function [x_pos, y_pos, theta] = convertToCartesian(theta, radius, isRadian)
            % Convert degrees to radians.
            if isRadian
                theta = pi/180*theta;
            end
            % Transform electrode locations from polar to cartesian coordinate.
            [x_pos, y_pos] = pol2cart(theta, radius);
        end
    end
end

