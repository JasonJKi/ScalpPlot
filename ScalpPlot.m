classdef ScalpPlot < handle
    % ScalpPlot creates spatial map of scalp recorded events such as
    % EEG or MEG. Ex: headPlotObj = ScalpPlot(locationFilepath)
    
    properties
        values
        LocationInfo = LocationInfo();
        PlotInfo
        headRadius = .5; % Default headradius to fit the head, nose, ear animation around the map.
        GridPoints = GridPoints();
        
        plotHandle;
        markerHandle;
        surfaceHandle = [];
    end

    methods
        
        function this = ScalpPlot(locationFilepath)
            % ScalpPlot creates spatial map of scalp recorded events such as
            % EEG or MEG. Ex: scalpPlotObj = ScalpPlot(locationFilepath)
            
            % Read location file for channel position relative to the scalp.
            [tmpeloc, labels, theta, radius, channelIndex] = readLocationFile(locationFilepath);
            
            % Transform the position from polar to cartesian coordinate.            
            [xPos, yPos, thetaDegrees] = this.convertToCartesian(theta, radius);
           
            % Set lcation points for the topoplot.
            setLocationValues(this, xPos, yPos, thetaDegrees, radius, tmpeloc, labels, channelIndex)
            this.setPlotHandle()
        end
        
        function setMap(this)            
            % Get position of the scalp.
            [xPos, yPos, radius] = getLocationValues(this);
            
            % Resize the location values to fit the plot and head radius.
            [xPos, yPos] = this.fitScalpPlotToAxes(xPos, yPos, radius, this.headRadius);
            this.LocationInfo.xPos = xPos;
            this.LocationInfo.yPos = yPos;
        end
        
        function setLocationValues(this, xPos, yPos, theta, radius, tmpeloc, labels, channelIndex)
            % Assign structure for location points
            this.LocationInfo.xPos = xPos;
            this.LocationInfo.yPos = yPos;
            this.LocationInfo.theta = theta;
            this.LocationInfo.radius = radius;
            this.LocationInfo.tmpeloc = tmpeloc;            
            this.LocationInfo.channelLabels = char(labels); % make a label string matrix            
            this.LocationInfo.channelIndex = channelIndex;
        end
        
        function [xPos, yPos, radius, theta, tmpeloc, channelLabels, channelIndex] = ... 
                getLocationValues(this)
            % Assign structure for location points
            xPos = this.LocationInfo.xPos;
            yPos = this.LocationInfo.yPos;
            theta = this.LocationInfo.theta;
            radius = this.LocationInfo.radius;
            tmpeloc = this.LocationInfo.tmpeloc;            
            channelLabels = this.LocationInfo.channelLabels;           
            channelIndex = this.LocationInfo.channelIndex ;
        end
        
        function setScalpPlotGridPoints(this, x, y, z, delta)
            this.GridPoints.x = x;
            this.GridPoints.y = y;
            this.GridPoints.z = z;
            this.GridPoints.delta = delta;
        end
        
        function [x, y, z, delta] = getGridPoints(this)
            x = this.GridPoints.x;
            y = this.GridPoints.y;
            z = this.GridPoints.z;
            delta = this.GridPoints.delta;
        end
        
        function setPlotHandle(this, plotHandle)
            if nargin < 2
                plotHandle = gca;
            end
            this.plotHandle = plotHandle;
            axes(this.plotHandle)
            this.formatPlotAxes(plotHandle)
            hold(plotHandle);
            hold on
            colormap(plotHandle, 'jet')
        end
        
        function plotHandle = getAxes(this)
            plotHandle = this.plotHandle;
        end
        
        function draw(this, values, plotHandle)
            if nargin < 3
                if isempty(this.plotHandle)
                    setAxes(this, gca)
                    axes(plotHandle)
                end
                axes(this.plotHandle)
            else
                setAxes(this, plotHandle);
                axes(plotHandle)
            end
            
            if nargin < 2
                values = this.values;
            end

            this.drawMaskHeadRing(this.headRadius);
            this.drawNoseAndEars(this.headRadius);

            if ~isempty(values)
                % Create plot points for the interpolated spatial map.
                setHeadMapValues(this, values)
            else
                return
            end
            [x, y, z, delta] = getGridPoints(this);
            this.surfaceHandle = this.drawInterpolatedHead(x, y, z, delta);
        end
        
        function setHeadMapValues(this, values)
                this.values = values;
                xPos = this.LocationInfo.xPos;
                yPos = this.LocationInfo.yPos;
            
                [x, y, z, delta] = this.createHeadSurfaceMap(xPos, yPos, values, this.headRadius);
                setScalpPlotGridPoints(this, x, y, z, delta);        
        end            
        
        function drawHeadContour(this, values)
            if nargin > 1
                setHeadMapValues(this, values)
            end
            
            if ~isempty(this.values)             
                [x, y, z, ~] = getGridPoints(this);
                this.drawContour(x, y, z);
            end
        end
        
        function drawSourcePoints(this)
            value = find(ones(1,length(this.LocationInfo.theta)));
            drawOnElectrode(this, value, '.', [0 0 0], [0 0 0]);
        end
        
        function markerHandle = drawOnElectrode(this, value, symbolStr, markerColor, markerFaceColor)
            if nargin < 3
                symbolStr =  '*';
            end
            
            if nargin < 4
                markerColor = [0 .7 .9];
            end
            
            if nargin < 5
                markerFaceColor = [.8 .8 .8];
            end
            
            markIndex = value;
            [x, y] = getLocationValues(this);
            markerHandle = plot(y(markIndex), x(markIndex), symbolStr, 'MarkerEdgeColor', ...
                markerColor , 'MarkerSize', 7, 'MarkerFaceColor', markerFaceColor);
        end
        
        function drawMarkerLegend(this, markerHandle, legendStr, location)
            if nargin < 4
                location = 'northwest';
            end
            figurePosition = get(this.plotHandle, 'Position');
            legend(markerHandle, legendStr, 'location', location, 'FontSize', 12);
            legend boxoff;
            set(this.plotHandle, 'Position', figurePosition);
        end
        
        function setColorAxis(this, range, colorMapVal)
            if nargin <3
                colorMapVal = jet;
            end
            absMin = range(1);
            absMax = range(2);
            caxis(this.plotHandle, [absMin absMax])
            colormap(this.plotHandle, colorMapVal)
        end
        
        function drawColorBar(this, cAxis, cAxisTickLabel, location)
            
            if nargin < 4
                location = 'southoutside';
            end
            figurePosition = get(this.plotHandle, 'Position');
            
            cAxisMax = cAxis(end);
            cAxisMin = cAxis(1);
            cbh = colorbar('location',location);
            set(cbh,'YTick',cAxis,'YTickLabel',cAxisTickLabel,'TickLabelInterpreter', 'tex','FontSize',10)
            set(cbh,'YLim',[cAxisMin,cAxisMax])
            set(this.plotHandle, 'Position', figurePosition)
        end
        
    end
    
    methods (Static)
        function [xPos, yPos, radius, resizRatio, maxLocRadius] = fitScalpPlotToAxes(xPos,yPos, radius, radiusMax)
            maxLocRadius = min(1.0,max(radius)*1.02);            % default: just outside the outermost electrode location
            maxLocRadius = max(maxLocRadius,0.5);
            
            resizRatio = radiusMax/maxLocRadius;
            
            radius = radius * resizRatio;
            xPos = xPos * resizRatio;
            yPos = yPos * resizRatio;
            
        end
        
        function [Xi, Yi, Zi, delta] = createHeadSurfaceMap(xPos, yPos, values, headRadius)
            % Create grid data for the plot location.
            xmin = -headRadius; xmax = headRadius;
            ymin = -headRadius; ymax = headRadius;
            
            GRID_SCALE = 100;
            xi = linspace(xmin, xmax, GRID_SCALE);   % x-axis description (row vector)
            yi = linspace(ymin, ymax, GRID_SCALE);   % y-axis description (row vector)
            delta = xi(2) - xi(1); % length of grid entry

            [Xi,Yi,Zi] = griddata(yPos, xPos, double(values), yi', xi, 'v4'); % interpolate data
            
            % Create a mask areas outside the head
            mask = (sqrt(Xi.^2 + Yi.^2) <= headRadius); % mask outside the plotting circle
            Zi(mask == 0)  = NaN;                         % mask non-plotting voxels with NaNs
        end
        
        function handleSurface = drawInterpolatedHead(Xi, Yi, Zi, delta)
            SHADING = 'flat';
            handleSurface = surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi))-0.1,Zi,...
                'EdgeColor','none','FaceColor',SHADING);            

            % Compute colormap axiS
            amax = max(max(abs(Zi)));
            amin = -amax;
            caxis([amin amax]);
        end
        
        function [cls, chs] = drawContour(X, Y, Z)
            % Draw contours
            numContours = 6;
            contourColor = 'k';
            [cls, chs] = contour(X,Y,Z,numContours,contourColor);
        end

        function drawMaskHeadRing(headRadius)
            HEADRINGWIDTH    = .005;% width of the cartoon head ring
            BLANKINGRINGWIDTH = .005;
            CIRCGRID = 201;  
            BACKCOLOR = [ 1 1 1 ];

            % 1. draw a headring over the surface to mask all pixelated
            % area.
            rwidth = BLANKINGRINGWIDTH;  
            hwidth = HEADRINGWIDTH;                   % width of head ring
             
            rin =  headRadius * (1-rwidth/2);              % inner ring radius
            hin  = rin;

            circ = linspace(0, 2*pi, CIRCGRID);
            rx = sin(circ);
            ry = cos(circ);
            ringx = [[rx(:)' rx(1) ]*(rin+rwidth)  [rx(:)' rx(1)]*rin];
            ringy = [[ry(:)' ry(1) ]*(rin+rwidth)  [ry(:)' ry(1)]*rin];
            patch(ringx,ringy,0.005*ones(size(ringx)),BACKCOLOR,'edgecolor','none');

            % 2. draw a headring to outline the head.
            HLINEWIDTH = 1;         % default linewidth for head, nose, ears
            HEADCOLOR = [0 0 0];    % default head color (black)
            
            headx = [rx(:)' rx(1)]*hin;
            heady = [ry(:)' ry(1)]*hin;
            ringh = plot(headx,heady);
            set(ringh, 'color',HEADCOLOR,'linewidth', 1.5);
            

        end
        
        function formatPlotAxes(handle, color, xTick, yTick)
            if nargin < 2 
                color = 'none';
                xTick = [];
                yTick = [];
            end
            
            set(handle,'XTick',xTick,'YTick', yTick)
            set(handle,'color',color)
            set(handle,'XColor',color,'YColor',color)
            axis square
        end
        
        function drawNoseAndEars(headRadius)
            base  = headRadius-.01;
            basex = 0.18*headRadius;                   % nose width
            tip   = 1.15*headRadius;
            tiphw = .04*headRadius;                    % nose tip half width
            tipr  = .01*headRadius;                    % nose tip rounding
            q = .04;                                   % ear lengthening
            EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005]; % maxLocRadius = 0.5
            EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];
            sf    = 1;
          
             % 2. draw a headring to outline the head.
            HLINEWIDTH = 1;         % default linewidth for head, nose, ears
            HEADCOLOR = [0 0 0];    % default head color (black)
            
            plot3([basex;tiphw;0;-tiphw;-basex]*sf,[base;tip-tipr;tip;tip-tipr;base]*sf,...
                2*ones(size([basex;tiphw;0;-tiphw;-basex])),...
                'Color',HEADCOLOR,'LineWidth',HLINEWIDTH);                 % plot nose
            plot3(EarX*sf,EarY*sf,2*ones(size(EarX)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)    % plot left ear
            plot3(-EarX*sf,EarY*sf,2*ones(size(EarY)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)   % plot right ear
        end
        
        function [x,y] = rotateScalpPlot(thetaRotation, x, y)
            allcoords = (y + x*sqrt(-1))*exp(sqrt(-1)*thetaRotation);
            x = imag(allcoords);
            y = real(allcoords);
        end
        
        function [xPos, yPos, thetaDegrees] = convertToCartesian(theta, radius)
            % Convert degrees to radians.
            theta = pi/180*theta; 
            % Transform electrode locations from polar to cartesian coordinate.
            [xPos, yPos] = pol2cart(theta, radius);     
            thetaDegrees = theta;
        end
       
    end
    
end

