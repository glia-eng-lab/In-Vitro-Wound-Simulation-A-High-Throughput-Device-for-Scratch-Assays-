clf;
close all;
clear;
clc;

inputDir = uigetdir(cd, "Select Input Directory");
outputDir = uigetdir(cd, "Select Output Directory");
imagejDir = uigetdir(cd, "Select Directory with ImageJ Summary Data for Comparison");

cd(imagejDir);
wellsImageJ = ls("*.csv");
cd(inputDir);
wells = ls("*.csv");
wellNum = size(wells, 1);
outputCell = cell(1 + wellNum, 12);
outputCell(1, :) = {'Well', 'Longest Shortest Path (px)', 'x1', 'y1', 'x2', 'y2', 'Linear Distance (px)', 'Tortuosity', '', 'ImageJ Longest Shortest Path (px)', 'ImageJ x', 'ImageJ y'};
for i = 1:wellNum
    wellPath = convertCharsToStrings(inputDir) + "\" + strip(convertCharsToStrings(wells(i, :)), 'right');
    inputData = readcell(wellPath);
    nodeCoordinates = unique(cell2mat([inputData(2:end, 3:4); inputData(2:end, 6:7)]), 'rows');

    skeletonGraph = graph(AdjacencyMatrix(inputData, nodeCoordinates));
    shortestPaths = distances(skeletonGraph);
    longestShortestPath = max(shortestPaths(:));

    [endIndex1, endIndex2] =  find(shortestPaths == longestShortestPath, 1);
    endPoint1 = nodeCoordinates(endIndex1, :);
    x1 = endPoint1(1);
    y1 = endPoint1(2);
    endPoint2 = nodeCoordinates(endIndex2, :);
    x2 = endPoint2(1);
    y2 = endPoint2(2);
    linearDistance = sqrt(((x2-x1)^2) + ((y2-y1)^2));

    wellName = split(convertCharsToStrings(wells(i, :)), "_");
    outputCell{1 + i, 1} = join(wellName(1:2), "_");
    outputCell{1 + i, 2} = longestShortestPath;
    outputCell{1 + i, 3} = x1;
    outputCell{1 + i, 4} = y1;
    outputCell{1 + i, 5} = x2;
    outputCell{1 + i, 6} = y2;
    outputCell{1 + i, 7} = linearDistance;
    outputCell{1 + i, 8} = longestShortestPath/linearDistance;

    imagejData = readcell(convertCharsToStrings(imagejDir) + "\" + strip(convertCharsToStrings(wellsImageJ(i, :)), 'right'));
    outputCell{1 + i, 10} = imagejData{2, 11};
    outputCell{1 + i, 11} = imagejData{2, 12};
    outputCell{1 + i, 12} = imagejData{2, 13};
end
cd(outputDir);
plateNumber = split(inputDir, '\');
writecell(outputCell, convertCharsToStrings(plateNumber{end, 1}) + ".csv");

function adjacencyMat = AdjacencyMatrix(input, nodes)
    A = Inf(size(nodes, 1));
    for j = 2:size(input, 1)
        index1 = find( sum(nodes == cell2mat( input(j, 3:4) ), 2) == 2 , 1, 'first');
        index2 = find( sum(nodes == cell2mat( input(j, 6:7) ), 2) == 2 , 1, 'first');
        A(index1, index2) = input{j, 2};
        A(index2, index1) = input{j, 2};
    end
    for k = 1:size(A, 1)
        A(k, k) = 0;
    end
    adjacencyMat = A;
end
