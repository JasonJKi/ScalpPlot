classdef ScalpPlot < handle
    % ScalpPlot creates spatial map of scalp recorded events such as
    % EEG or MEG. Ex: headPlotObj = ScalpPlot(locationFilepath)
    
    properties
        values
        PlotInfo
        headRadius = .5; % Default headradius to fit the head, nose, ear animation around the map.
        gridPoints = GridPoints();
        
        plotHandle;
        markerHandle;
        surfaceHandle = [];

        locationInfo = LocationInfo();
        xPos
        yPos
    end

    methods
        
        function this = ScalpPlot(locationInfo)
            % ScalpPlot creates spatial map of scalp recorded events such as
            % EEG or MEG. Ex: scalpPlotObj = ScalpPlot(locationFilepath)
            
            setMap(this, locationInfo)
            % Set lcation points for the topoplot.
        end
       
        function setMap(this, locationInfo)
            this.locationInfo = locationInfo.getLocationInfo();
            % Get position of the scalp.
            [xPos_, yPos_, radius] = this.locationInfo.getLocationValues();
            
            % Resize the location values to fit the plot and head radius.
            [xPosResized, yPosResized] = this.fitScalpPlotToAxes(xPos_, yPos_, radius, this.headRadius);
            setPlotXYPositions(this, xPosResized, yPosResized)
        end
        
        function setPlotXYPositions(this, xPos, yPos)
            this.xPos = xPos;
            this.yPos = yPos;
        end
        
        function [xPos, yPos] = getPlotXYPositions(this)
            xPos = this.xPos;
            yPos = this.yPos;
        end
                
        function setPlotGridPoints(this, x, y, z, delta)
            this.gridPoints.x = x;
            this.gridPoints.y = y;
            this.gridPoints.z = z;
            this.gridPoints.delta = delta;
        end
        
        function [x, y, z, delta] = getgridPoints(this)
            x = this.gridPoints.x;
            y = this.gridPoints.y;
            z = this.gridPoints.z;
            delta = this.gridPoints.delta;
        end
        
        function setPlotHandle(this, plotHandle)
            this.plotHandle = plotHandle;
            axes(this.plotHandle)
            this.formatPlotAxes(plotHandle)
            hold(plotHandle);
            colormap(plotHandle, 'jet')
        end
        
        function plotHandle = getAxes(this)
            plotHandle = this.plotHandle;
        end
        
        function draw(this, values)
            if nargin < 2
                values = this.values;
            end

            this.drawMaskHeadRing(this.headRadius);
            this.drawNoseAndEars(this.headRadius);
            
            [xPos_, yPos_] = getPlotXYPositions(this);            
            setHeadMapValues(this, values, xPos_, yPos_);
            
            [x, y, z, delta] = getgridPoints(this);
            this.drawInterpolatedHead(x, y, z, delta);
            
            xlim([-.6 .6])
            ylim([-.6 .6])
        end
        
        function setHeadMapValues(this, values, xPos, yPos)
                this.values = values;            
                [x, y, z, delta] = this.createHeadSurfaceMap(xPos, yPos, values, this.headRadius);
                setPlotGridPoints(this, x, y, z, delta);        
        end
        
        function drawHeadContour(this, values, xPos, yPos)
            if nargin > 1
                setHeadMapValues(this, values, xPos, yPos)
            end
            
            if ~isempty(this.values)             
                [x, y, z, ~] = getgridPoints(this);
                this.drawContour(x, y, z);
            end
        end
        
        function drawSourcePoints(this)
            value = find(ones(1,length(this.locationInfo.theta)));
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
           [xPos_, yPos_] = this.getPlotXYPositions();
            markerHandle = plot(xPos_(markIndex), yPos_(markIndex), symbolStr, 'MarkerEdgeColor', ...
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
                location = 'westoutside';
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
        function [xPos, yPos, radius, resizRatio, maxLocRadius] = fitScalpPlotToAxes(xPos, yPos, radius, radiusMax)
            maxLocRadius = min(1.0,max(radius)*1.02);            % default: just outside the outermost electrode location
            maxLocRadius = max(maxLocRadius,0.5);
            
            resizRatio = radiusMax/maxLocRadius;
            
            radius = radius * resizRatio;
            xPos = xPos * resizRatio;
            yPos = yPos * resizRatio;
            
        end
        
        function [X, Y, Z, delta] = createHeadSurfaceMap(xPos, yPos, values, headRadius)
            % Create grid data for the plot location.
            xmin = -headRadius; xmax = headRadius;
            ymin = -headRadius; ymax = headRadius;
            
            GRID_SCALE = 100;
            xi = linspace(xmin, xmax, GRID_SCALE);   % x-axis description (row vector)
            yi = linspace(ymin, ymax, GRID_SCALE);   % y-axis description (row vector)
            delta = xi(2) - xi(1); % length of grid entry

            [X, Y, Z] = griddata(yPos, xPos, double(values), yi', xi, 'v4'); % interpolate data
            
            % Create a mask areas outside the head
            mask = (sqrt(X.^2 + Y.^2) <= headRadius); % mask outside the plotting circle
            Z(mask == 0)  = NaN;                         % mask non-plotting voxels with NaNs
        end
        
        function drawInterpolatedHead(X, Y, Z, delta)
            SHADING = 'flat';
            
            x = X-delta/2;
            y = Y-delta/2;
            z = zeros(size(Z));
            c = Z;
            surface(x,y,z,c,...
                'EdgeColor','none','FaceColor',SHADING);            

            % Compute colormap axiS
            amax = max(max(abs(c)));
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
        
     
    end
    
end

