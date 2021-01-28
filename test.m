% Test Classifiers Accuracy

clear all;
close all;

load("classifier_knn");
load("classifier_bayes");

% TEST SHAPES
% Load Ground Truths (file name represents the label)
[gt_props, gt_labels] = load_shapes("./shapes_gt/");

% Predict Labels with KNN Classifier
pred_labels = predict(classifier_knn, gt_props);

cm_shapes = confmat(gt_labels, pred_labels);

figure, heatmap(cm_shapes.cm), title("Confusion Matrix");
figure, heatmap(cm_shapes.cm_raw), title("Confusion Matrix");

% TEST SEGMENTATION
ims = ["P04", "P06", "P07"];
gt_labels = [];
test_props = [];

for i = 1:length(ims)
    gt = logical(im2gray(imread("./scenes_gt/" + ims(i) + ".png")));
    gt_labels = [gt_labels; reshape(gt, size(gt, 1) * size(gt, 2), 1)];
    
    imrgb = imread("./scenes/" + ims(i) + ".jpg");
    imycbcr = rgb2ycbcr(imrgb);
    values = cat(3, imrgb(:, :, 2:3), imycbcr);
    [r, c, ch] = size(values);
    test_props = [test_props; double(reshape(values, r*c, ch))];
end

% Predict labels with Bayesian Classifier
pred_labels = predict(classifier_bayes, test_props);

cm_colors = confmat(gt_labels, pred_labels);
figure, heatmap(cm_colors.cm), title("Confusion Matrix");
figure, heatmap(cm_colors.cm_raw), title("Confusion Matrix");