function score = ENIQA(img)
% The input parameter img could be the image object or the path string
if ischar(img)
	img = imread(img);
end

load('C:\Users\user\OneDrive\IQM\metrics\13_ENIQA\ENIQA-master\ENIQA_release\model\models.mat')	% Load the models pretrained on LIVE
% load('models')

whos

scale = 2;
feature = featureExtract56(img, scale);
score = predict(feature, svrmodels, svcmodel);


