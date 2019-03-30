# HeadPlot

#### Headplot is a easy-to-use/customizable plot tool for drawing scalp maps of EEG/MEG data in MATLAB. 

<p>
    <img src='output/demo.png' width=800 />
</p>

### Features
- Consistent positioning and sizing (no gaps/extra space/constant sizing).
- Easy to customize labels, colors, etc.
- Draggable and resizable via MATLAB's plot GUI Tool.
- Lightweight.

### Motivation
HeadPlot has been deconstructed from the popular topoplot.m from EEGLab by Schwartz Lab at UCSD. 
The original code has been cleaned up and refactored for readability and organization. Headplot aims to be user friendly, easy-to-use
plot tool for both researchers and developers. All unnecessary depedenecis have been removed from the original topoplot.m for easy transportability.

# Getting Started
### Installation
- Linux/Windows/Mac
- MATLAB

1) In OS command prompt.
```
git clone https://github.com/JasonJKi/HeadPlot.git
cd HeadPlot
```

2) In matlab
```
setup install save
```

### Usage

#### From demo.m

Instantiate the HeadPlot object once for all headplots. 

```
headPlot = HeadPlot(locationFilePath);
headPlot.setMap();
```

Set plot handle for easy control/customizability
```
plotHandle1 = subplot(1,6,1)
plotHandle2 = subplot(1,6,2)
plotHandle3 = subplot(1,6,3)
.
.
.
```


Ex 1. Draw the default headplot in the first plot.
```
headPlot.setPlotHandle(plotHandle1); % Set plot handle and plot axes
headPlot.draw(A); % Draw headplot. A - Some scalp recording data/ forward model/ weights/ dipoles/ etc.
title('Ex 1: default headplot')
```
Ex 2. Head plot with contours.
```
headPlot.setPlotHandle(plotHandle2); % Set plot handle and plot axes
headPlot.draw(A);
headPlot.drawHeadContour();
title('Ex 2: w/ contour')
```
Ex 3. Head plot with value of source points.
```
headPlot.setPlotHandle(plotHandle3); % Set plot handle and plot axes
headPlot.draw(A);
headPlot.drawSourcePoints();
title('Ex 3: w/ source location')
```
Ex 4. Head plot with specified values on selective source points.
```
headPlot.setPlotHandle(plotHandle4); % Set plot handle and plot axes
headPlot.draw(A);
```
```
symbolStr = '^'; #'*', 'o', '.', 'x'
```
Any of Matlab's markers can be chosen from this list.
https://www.mathworks.com/help/matlab/ref/linespec.html

```
sourceIndex = (rand(1,96) > .5);
markerHandle1 = headPlot.drawOnElectrode(sourceIndex, symbolStr, [.5 .5 0],[1 .5 0]); % plot on siginficnt points
markerHandle2 = headPlot.drawOnElectrode(~sourceIndex, symbolStr, [0 .5 .5], [0 .5 1]); % plot on siginficnt points
handles = [markerHandle1 markerHandle2];
headPlot.drawMarkerLegend(handles, {'marker 1', 'marker 2'} ,'southwestoutside');
title('Ex 4: w/ specified source markers')
```
Ex5. Head plot with specified colormap and axis.
```
headPlot.setPlotHandle(plotHandle5); % Set plot handle and plot axes
headPlot.draw(A);
```

```
colorMapVal = flipud(hot); % Assign colormap scale
```
Any of Matlab's custom color maps can be chosen from this list.
https://www.mathworks.com/help/matlab/ref/colormap.html#buc3wsn-1-map

```
maxVal = max(A); minVal = min(A); % Set color min and max values.
colorAxisRange = [minVal maxVal];
cAxis = [minVal, mean(A), maxVal];
cAxisTickLabel = {num2str(minVal, '%0.3f'), '\muV', num2str(maxVal,'%0.3f')};

headPlot.setColorAxis(colorAxisRange, colorMapVal); % Set color scale.
headPlot.drawColorBar(cAxis, cAxisTickLabel, 'southoutside');  % Draw color bar.
```



## Contact
Feel free to contact me at (Jason Ki ki.jasonj@gmail.com). 

## Contributions
Contribution to headplot is welcomed. 
