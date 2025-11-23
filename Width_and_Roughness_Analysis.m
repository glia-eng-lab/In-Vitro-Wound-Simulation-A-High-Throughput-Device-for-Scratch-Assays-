clf;
close all;
clear;
clc;

inputDir = uigetdir(cd, "(1) Select TIFF Input Directory for Width and Roughness Analysis");   
widthDir = uigetdir(cd, "(2) Select Directory for Width Measurement Output");
roughnessDir = uigetdir(cd, "(3) Select Directory for Roughness Measurement Output");
widthImageDir = uigetdir(cd, "(4) Select Directory for Width Analysis Image Output");
roughnessImageDir = uigetdir(cd, "(5) Select Directory for Roughness Analysis Image Output");

cd(inputDir);
wells = ls("*.tif");
wellNum = size(wells, 1);

widthData = cell(1 + wellNum, 6);
roughnessData = cell(1 + wellNum, 2);
widthData(1, :) = {'Well', 'Width (px)', 'Uncorrected Width (px)', 'Left Angle (degrees)', 'Right Angle (degrees)', 'Average Angle (degrees)'};
roughnessData(1, :) = {'Well', 'Average Roughness (px)'};
for i = 1:wellNum
    wellPath = convertCharsToStrings(inputDir) + "\" + strip(convertCharsToStrings(wells(i, :)), 'right');
    binMatrix = binarizeMatrix(wellPath);
    [left, right] = getBoundaries(binMatrix);

    roughnessData{i + 1, 1} = convertCharsToStrings(wells(i, :));
    widthData{i + 1, 1} = convertCharsToStrings(wells(i, :));
    roughnessData{i + 1, 2} = 0.5*(calculateRoughness(left(:, 1), left(:, 2)) + calculateRoughness(right(:, 1), right(:, 2)));
    widthData{i + 1, 2} = analyzeWidth(binMatrix, computeAverageAngle(left(:, 1), left(:, 2), right(:, 1), right(:, 2)));
    widthData{i + 1, 3} = sum(binMatrix, "all")*(1/size(binMatrix, 1));

    figure(1);
    imshow(binMatrix);
    hold on;
    plot(right(:, 2), right(:, 1), 'r', 'LineWidth', 2);
    plot(left(:, 2), left(:, 1), 'b', 'LineWidth', 2);

    figure(2);
    fitR = polyfit(right(:, 1), right(:, 2), 1);
    mR = fitR(1);
    bR = fitR(2);
    fitL = polyfit(left(:, 1), left(:, 2), 1);
    mL = fitL(1);
    bL = fitL(2);
    imshow(binMatrix);
    hold on;
    plot(mR*right(:, 1) + bR, right(:, 1), 'r:', 'LineWidth', 2);
    plot(mL*left(:, 1) + bL, left(:, 1), 'b:', 'LineWidth', 2);
    legend("\theta_{1} = " + num2str(atan(mR)) + " rad = " + num2str(atand(mR)) + "^{\circ}", "\theta_{2} = " + num2str(atan(mL)) + " rad = " + num2str(atand(mL)) + "^{\circ}", ...
        'Location', 'northeast', 'FontWeight','bold', 'FontSize', 14);
    widthData{i + 1, 4} = atand(mL);
    widthData{i + 1, 5} = atand(mR);
    widthData{i + 1, 6} = 0.5*(widthData{i + 1, 4} + widthData{i + 1, 5});

    figure(3);
    fitR2 = polyfit(right(:, 1), right(:, 2), 1);
    mR2 = fitR2(1);
    bR2 = fitR2(2);
    subplot(4, 1, 1);
    plot(right(:, 1), right(:, 2), 'r', 'LineWidth', 2);
    hold on;
    plot(right(:, 1), mR2 * right(:, 1) + bR2, 'r:');
    subplot(4, 1, 2);
    plot(right(:, 1), right(:, 2) - (mR2 * right(:, 1) + bR2), 'r', 'LineWidth', 2);
    subplot(4, 1, 3);
    plot(right(:, 1), right(:, 2) - (mR2 * right(:, 1) + bR2) - mean(right(:, 2) - (mR2 * right(:, 1) + bR2)), 'r', 'LineWidth', 2);
    subplot(4, 1, 4);
    plot(right(:, 1), abs(right(:, 2) - (mR2 * right(:, 1) + bR2) - mean(right(:, 2) - (mR2 * right(:, 1) + bR2))), 'r', 'LineWidth', 2);
    hold on;
    plot(right(:, 1), ( ones(size( right(:, 1), 1 ), size( right(:, 1), 2 ) ) )*calculateRoughness(right(:, 1), right(:, 2)), 'r:');

    figure(4);
    fitL2 = polyfit(left(:, 1), left(:, 2), 1);
    mL2 = fitL2(1);
    bL2 = fitL2(2);
    subplot(4, 1, 1);
    plot(left(:, 1), left(:, 2), 'b', 'LineWidth', 2);
    hold on;
    plot(left(:, 1), mL2 * left(:, 1) + bL2, 'b:');
    subplot(4, 1, 2);
    plot(left(:, 1), left(:, 2) - (mL2 * left(:, 1) + bL2), 'b', 'LineWidth', 2);
    subplot(4, 1, 3);
    plot(left(:, 1), left(:, 2) - (mL2 * left(:, 1) + bL2) - mean(left(:, 2) - (mL2 * left(:, 1) + bL2)), 'b', 'LineWidth', 2);
    subplot(4, 1, 4);
    plot(left(:, 1), abs(left(:, 2) - (mL2 * left(:, 1) + bL2) - mean(left(:, 2) - (mL2 * left(:, 1) + bL2))), 'b', 'LineWidth', 2);
    hold on;
    plot(left(:, 1), ( ones(size( left(:, 1), 1 ), size( left(:, 1), 2 ) ) )*calculateRoughness(left(:, 1), left(:, 2)), 'b:');

    cd(widthImageDir);
    saveas(figure(1), convertCharsToStrings(wells(i, :)) + "_Boundary.jpg");
    saveas(figure(2), convertCharsToStrings(wells(i, :)) + "_Linear.jpg");

    cd(roughnessImageDir);
    saveas(figure(3), convertCharsToStrings(wells(i, :)) + "_Right.jpg");
    saveas(figure(4), convertCharsToStrings(wells(i, :)) + "_Left.jpg");

    clf(figure(1));
    clf(figure(2));
    clf(figure(3));
    clf(figure(4));
end
cd(widthDir);
plate_number = split(inputDir, '\');
writecell(widthData, convertCharsToStrings(plate_number{end, 1}) + ".csv");
cd(roughnessDir);
writecell(roughnessData, convertCharsToStrings(plate_number{end, 1}) + ".csv");
close all;
clc;

function binMatrix = binarizeMatrix(image_path)
    wellTIFF = Tiff(image_path);
    wellMat = read(wellTIFF);
    logicalMat = wellMat > 0;
    binMatrix = logicalMat*1;
end

function [leftBoundary, rightBoundary] = getBoundaries(binMatrix)
    boundary = bwtraceboundary(binMatrix, [1, find(binMatrix(1, :), 1, 'first');], 'E', 8);
    boundaryTrimmed = (boundary(:, 1) ~= 1) & (boundary(:, 1) ~= size(binMatrix, 1));
    endpoints = [boundaryTrimmed; 0] - [0; boundaryTrimmed];
    startpoints = find(endpoints > 0);
    lengths = find(endpoints < 0) - startpoints;
    maxLengths = maxk(lengths, 2);
    if maxLengths(1) == maxLengths(2)
        start = startpoints(lengths == maxLengths(1));
        boundary1 = boundary((start(1) - 1) : (start(1) + maxLengths(1)), :);
        boundary2 = boundary((start(2) - 1) : (start(2) + maxLengths(2)), :);
        if boundary1(1, 2) > boundary2(1, 2)
            rightBoundary = boundary1;
            leftBoundary = boundary2;
        else
            rightBoundary = boundary2;
            leftBoundary = boundary1;
        end
    else
        start1 = startpoints(lengths == maxLengths(1));
        start2 = startpoints(lengths == maxLengths(2));
        boundary1 = boundary((start1 - 1) : (start1 + maxLengths(1)), :);
        boundary2 = boundary((start2 - 1) : (start2 + maxLengths(2)), :);
        if boundary1(1, 2) > boundary2(1, 2)
            rightBoundary = boundary1;
            leftBoundary = boundary2;
        else
            rightBoundary = boundary2;
            leftBoundary = boundary1;
        end
    end
end

function averageRoughness = calculateRoughness(x, y)
    fit = polyfit(x, y, 1);
    m = fit(1);
    b = fit(2);
    yBaseline = y - (m*x + b);
    averageRoughness = mean(abs(yBaseline - mean(yBaseline)));
end

function averageAngle = computeAverageAngle(x1, y1, x2, y2)
    % returns radians, not degrees
    m1 = polyfit(x1, y1, 1);
    m2 = polyfit(x2, y2, 1);
    averageAngle = 0.5*(atan(m1(1)) + atan(m2(1)));
end

function meanWidth = analyzeWidth(binMatrix, theta)
    height = size(binMatrix, 1);
    meanWidth = sum(binMatrix, "all")*(cos(theta))*(1/height);
end