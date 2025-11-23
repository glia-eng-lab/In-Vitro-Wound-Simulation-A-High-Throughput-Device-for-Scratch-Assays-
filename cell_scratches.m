clf;
close all;
clear;
clc;

inputDir = uigetdir(cd, "(1) Select TIFF Input Directory");
widthDataDir = uigetdir(cd, "(2) Select Directory for Width Measurement Output");
widthImageDir = uigetdir(cd, "(3) Select Directory for Width Analysis Image Output");
linearImageDir = uigetdir(cd, "(4) Select Directory for Width Analysis Image Output with Best Fit Lines");

cd(inputDir);
wells = ls("*.tif");
wellNum = size(wells, 1);

widthData = cell(1 + wellNum, 8);
widthData(1, :) = {'Well', 'Width Over 2mm (px)', 'Width Over Full Image (px)', 'Left Angle (degrees)', 'Right Angle (degrees)', 'Average Angle (degrees)', 'Uncorrected Width Over 2mm (px)', 'Uncorrected Width Over Full Image (px)'};
twoMM = 3077;

for i = 1:wellNum
    wellPath = convertCharsToStrings(inputDir) + "\" + strip(convertCharsToStrings(wells(i, :)), 'right');
    binMatrix = binarizeMatrix(wellPath);
    col = halve(binMatrix);
    [leftCoordinates, rightCoordinates] = findBoundaries(binMatrix, col);
    cutoff = 0.5;
    leftBound = smooth(leftCoordinates, cutoff);
    rightBound = smooth(rightCoordinates, cutoff);
    leftCol = 1 + col - leftBound';
    rightCol = col + flip(rightBound', 1);
    startingRow = 1 + round(0.5*size(binMatrix, 1) - 0.5*twoMM);
    widths = max(0, rightCol - leftCol);
    
    widthData{i + 1, 7} = mean(widths( startingRow:(startingRow + twoMM - 1) ));
    widthData{i + 1, 2} = (widthData{i + 1, 7}) * cos( computeAverageAngle(1:length(leftCol), leftCol, 1:length(rightCol), rightCol) );

    widthData{i + 1, 8} = mean(widths);
    widthData{i + 1, 3} = (widthData{i + 1, 8}) * cos( computeAverageAngle(1:length(leftCol), leftCol, 1:length(rightCol), rightCol) );

    widthData{i + 1, 1} = convertCharsToStrings(wells(i, :));

    
    figure(1);
    clf;
    imshow(binMatrix);
    hold on;
    % plot(leftCol( startingRow:(startingRow + twoMM - 1) ), startingRow:(startingRow + twoMM - 1), 'r', 'LineWidth', 2);
    % plot(rightCol( startingRow:(startingRow + twoMM - 1) ), startingRow:(startingRow + twoMM - 1), 'r', 'LineWidth', 2);
    plot(leftCol, 1:length(leftCol), 'r', 'LineWidth', 2);
    plot(rightCol, 1:length(rightCol), 'r', 'LineWidth', 2);
    cd(widthImageDir);
    saveas(figure(1), convertCharsToStrings(wells(i, :)) + ".jpg");

    figure(2);
    clf;
    fitL = polyfit(1:length(leftCol), leftCol, 1);
    mL = fitL(1);
    bL = fitL(2);
    fitR = polyfit(1:length(rightCol), rightCol, 1);
    mR = fitR(1);
    bR = fitR(2);
    imshow(binMatrix);
    hold on; 
    plot(leftCol, 1:length(leftCol), 'b', 'LineWidth', 2);
    plot(rightCol, 1:length(rightCol), 'r', 'LineWidth', 2);
    plot(mL*( 1:length(leftCol) ) + bL, 1:length(leftCol), 'b:', 'LineWidth', 2);
    plot(mR*( 1:length(rightCol) ) + bR, 1:length(rightCol), 'r:', 'LineWidth', 2);
    legend("\theta_{1} = " + num2str(atan(mL)) + " rad = " + num2str(atand(mL)) + "^{\circ}", "\theta_{2} = " + num2str(atan(mR)) + " rad = " + num2str(atand(mR)) + "^{\circ}", ...
        'Location', 'northeast', 'FontWeight','bold', 'FontSize', 14);
    
    widthData{i + 1, 4} = atand(mL);
    widthData{i + 1, 5} = atand(mR);
    widthData{i + 1, 6} = 0.5*(widthData{i + 1, 4} + widthData{i + 1, 5});
    cd(linearImageDir);
    saveas(figure(2), convertCharsToStrings(wells(i, :)) + ".jpg");
end
cd(widthDataDir);
fileName = split(inputDir, '\');
writecell(widthData, convertCharsToStrings(fileName{end, 1}) + ".csv");

function binMatrix = binarizeMatrix(image_path)
    wellTIFF = Tiff(image_path);
    wellMat = read(wellTIFF);
    logicalMat = wellMat > 0;
    binMatrix = logicalMat*1;
end

function [leftCoordinates, rightCoordinates] = findBoundaries(binMatrix, col)
    leftHalf = rot90(binMatrix(:, 1:col));
    rightHalf = rot90(binMatrix(:, (col + 1):end), 3);
    leftCoordinates = zeros(1, size(leftHalf, 2));
    for j = 1:size(leftHalf, 2)
        if ~isempty(find(leftHalf(:, j), 1))
            leftCoordinates(j) = find(leftHalf(:, j), 1);
        else
            if j ~= 1
                leftCoordinates(j) = leftCoordinates(j-1);
            else
                leftCoordinates(j) = round(0.5*length(leftCoordinates));
            end
        end
    end

    rightCoordinates = zeros(1, size(rightHalf, 2));
    for k = 1:size(rightHalf, 2)
        if ~isempty(find(rightHalf(:, k), 1))
            rightCoordinates(k) = find(rightHalf(:, k), 1);
        else
            if k ~= 1
                rightCoordinates(k) = rightCoordinates(k-1);
            else
                rightCoordinates(k) = round(0.5*length(rightCoordinates));
            end
        end
    end
end

function midline = halve(binMatrix)
    emptyColumns = find(sum(binMatrix, 1) == 0);
    if isempty(emptyColumns)
        col = round(0.5 * size(binMatrix, 2));
    else
        distanceFromCenter = abs(emptyColumns - round(0.5 * size(binMatrix, 2)));
        if min(distanceFromCenter) < 1000
            [~, minIndex] = min(distanceFromCenter);
            col = emptyColumns(minIndex);
        else
            col = round(0.5 * size(binMatrix, 2));
        end
    end
    midline = col;
end

function smoothedCurve = smooth(coordinates, cutoff)
    original = coordinates;
    iteration = original;
    original = iteration;
    secondDerivative = [0, diff(iteration, 2), 0];
    while any(secondDerivative > cutoff)
        iteration = 0.5*[iteration(2:end), iteration(end)] + 0.5*[iteration(1), iteration(1:(end - 1))];
        valid = iteration < original;
        iteration = iteration .* valid + original .* ~valid;
        secondDerivative = [0, diff(iteration, 2), 0];
    end
    smoothedCurve = iteration;
end

function averageAngle = computeAverageAngle(x1, y1, x2, y2)
    % returns radians, not degrees
    m1 = polyfit(x1, y1, 1);
    m2 = polyfit(x2, y2, 1);
    averageAngle = 0.5*(atan(m1(1)) + atan(m2(1)));
end