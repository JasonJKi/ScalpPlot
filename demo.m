% This script demonstrates headplot for simple interpolation.
setup install

% Load in demo data.
demoDataPath = 'res/demo_data.mat';
data = load(demoDataPath, 'scalActivity');
A = data.scalActivity(:,1); % Forward model.

% Set location file filepath.
locationFilePath = 'res/96_EEG.loc';

% Demonstration of customizable headplot.
figure(1);clf
plotHandle1 = subplot(2,3,1); 
plotHandle2 = subplot(2,3,2);
plotHandle3 = subplot(2,3,3); 
plotHandle4 = subplot(2,3,4); 
plotHandle5 = subplot(2,3,5);
plotHandle6 = subplot(2,3,6); 

% Instantiate the HeadPlot object. 
headPlot = HeadPlot(locationFilePath);
headPlot.setMap();

% Ex 1. Draw the default headplot in the first plot.
headPlot.setPlotHandle(plotHandle1); % Set plot handle and plot axes
headPlot.draw(A); % Draw headplot.
title('Ex 1: default headplot')

% Ex 2. Head plot with contours.
headPlot.setPlotHandle(plotHandle2); % Set plot handle and plot axes
headPlot.draw(A);
headPlot.drawHeadContour();
title('Ex 2: w/ contour')

% Ex 3. Head plot with value of source points.
headPlot.setPlotHandle(plotHandle3); % Set plot handle and plot axes
headPlot.draw(A);
headPlot.drawSourcePoints();
title('Ex 3: w/ source location')

% Ex 4. Head plot with specified values on selective source points.
headPlot.setPlotHandle(plotHandle4); % Set plot handle and plot axes
headPlot.draw(A);

symbolStr = '^';
sourceIndex = (rand(1,96) > .5);
markerHandle1 = headPlot.drawOnElectrode(sourceIndex, symbolStr, [.5 .5 0],[1 .5 0]); % plot on siginficnt points
markerHandle2 = headPlot.drawOnElectrode(~sourceIndex, symbolStr, [0 .5 .5], [0 .5 1]); % plot on siginficnt points
handles = [markerHandle1 markerHandle2];
headPlot.drawMarkerLegend(handles, {'marker 1', 'marker 2'} ,'southwestoutside');
title('Ex 4: w/ specified source markers')

% Ex5. Head plot with specified colormap and axis.
headPlot.setPlotHandle(plotHandle5); % Set plot handle and plot axes
headPlot.draw(A);

colorMapVal = flipud(hot); % Assign colormap scale

maxVal = max(A); minVal = min(A); % Set color min and max values.
colorAxisRange = [minVal maxVal];
cAxis = [minVal, mean(A), maxVal];
cAxisTickLabel = {num2str(minVal, '%0.3f'), '\muV', num2str(maxVal,'%0.3f')};

headPlot.setColorAxis(colorAxisRange, colorMapVal); % Set color scale.
headPlot.drawColorBar(cAxis, cAxisTickLabel, 'southoutside');  % Draw color bar.

title('Ex 5: w/ colorbar and alternate color scale')

print('output/demo','-dpng','-r0');
