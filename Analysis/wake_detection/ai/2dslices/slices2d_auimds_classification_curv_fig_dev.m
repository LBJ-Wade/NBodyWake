function [  ] = slices2d_auimds_classification_curv_fig_dev()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% slices2d_ds( root,root_data_2d_in,root_data_2d_anali,spec,aux_path,aux_path_out,filename,lenght_factor,resol_factor,numb_rand,slice,NSIDE ,num_cores)

%(example)  [ map ,anali] = slices2d_ds('/home/asus/Dropbox/extras/storage/graham/small_res/','/home/asus/Dropbox/extras/storage/graham/small_res/data_test2/','/home/asus/Dropbox/extras/storage/graham/small_res/anali/','64Mpc_256c_128p_zi63_nowakem','/sample2001/','','10.000xv0.dat',1,1,1,2,2,1);

 

% myCluster = parcluster('local');
% myCluster.NumWorkers=num_cores;
% saveProfile(myCluster);
% 
% p = parpool(num_cores);




filename='_2dproj_z3_data_sl';
nc=1024;
% trsh=20;
% cut=1;
% lev=2;
% sigma = 5;
slices=32;
% anal_lev=2;
NSIDE=16;
resol_factor=1;
lenght_factor=1;

% specs_path_list_nowake='/home/asus/Dropbox/extras/storage/graham/ht/data_cps32_1024_2a3dcurvfilt/4Mpc_2048c_1024p_zi63_nowakem'
specs_path_list_nowake='/home/asus/Dropbox/extras/storage/graham/ht/data_cps32_hpx_2d_NSIDE16_fig/4Mpc_2048c_1024p_zi63_nowakem'
sample_list_nowake=dir(strcat(specs_path_list_nowake,'/sample*'));
sample_list_nowake={sample_list_nowake.name};
% sample_list_nowake=sort_nat(sample_list_nowake)
% 
% specs_path_list_wake='/home/asus/Dropbox/extras/storage/graham/ht/data_cps32_1024_2a3dcurvfilt/4Mpc_2048c_1024p_zi63_wakeGmu1t10m7zi10m'
specs_path_list_wake='/home/asus/Dropbox/extras/storage/graham/ht/data_cps32_hpx_2d_NSIDE16_wake_fig/4Mpc_2048c_1024p_zi63_wakeGmu1t10m7zi10m'
sample_list_wake=dir(strcat(specs_path_list_wake,'/sample*'));
sample_list_wake={sample_list_wake.name};
sample_list_wake=strcat(sample_list_wake,'/half_lin_cutoff_half_tot_pert_nvpw');
% sample_list_wake=sort_nat(sample_list_wake)

sample_id_range=[1 : length(sample_list_nowake)];

count=1;

N_angles=12*NSIDE*NSIDE/2;

for w_nw=1:2
    % for w_nw=1:1
    
    if w_nw==1
        specs_path_list=specs_path_list_nowake;
        sample_list=sample_list_nowake;
        ch='_7';
        coul='b';
    else
        specs_path_list=specs_path_list_wake;
        sample_list=sample_list_wake;
        ch='_4';
        coul='r';
    end
    
    
    for sample = 1:length(sample_id_range)
        %     for sample = 1:1
        
        %         map_3d_slices=zeros(nc,nc,slices);
        %         map_3d_slices_filt2d=zeros(nc,nc,slices);
        
%          for angle_id=1:N_angles
        for angle_id=1:1
            
            
            
            %         for slice_id=1:1
            
            %                 sample_id=(slices*(sample-1))+slice_id;
            
            %             filename_nowake=strcat('',specs_path_list,'/',string(sample_list(sample)),'/data/1lf_1rf_0-0-0pv_1.5708-0-0ra/2dproj/dm/2d_curvfilt/',ch,filename,num2str(slice_id),'_curvfilt2a3d','.bin');
            %             filename_nowake=strcat('',specs_path_list,'/',string(sample_list(sample)),'/data/1lf_1rf/_0-0-0pv_1.5708-0-0ra/2dproj/dm/2a3d_curvfilt/',ch,filename,num2str(slice_id),'_fcurvfilt2a3d3col','.png');
            path1=strcat('',specs_path_list,'/',string(sample_list(sample)),'/data/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf','/NSIDE_',num2str(NSIDE),'/anglid_',num2str(angle_id),'/');
            
            path2=dir(char(strcat(path1,"*pv*")));
            
            path2={path2.name}
            path2=path2(1);
            
            path3='/2dproj/dm/';
            
            path_in=strcat('',specs_path_list,'/',string(sample_list(sample)),'/data/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf','/NSIDE_',num2str(NSIDE),'/anglid_',num2str(angle_id),'/',path2,'/2dproj/dm/');
            
            for slice_id=1:slices
                
                
                filename_nowake=string(strcat(path_in,ch,filename,num2str(slice_id),'_fcurvfilt2a3d3col','.png'));
                
                %              for slice_id=1:slices
                
                filename_nowake=char(filename_nowake);
                %             %             fid = fopen(filename_nowake);
                %             %         scalefactor = fread(fid, [1 1], 'float32','l') ;
                % %             display(filename_nowake)
                %             slice_2d_ds = fileDatastore(filename_nowake,'ReadFcn',@read_slices_bin,'FileExtensions','.bin');
                %             slice_2d=cell2mat(tall(slice_2d_ds));
                %
                %             figure; imagesc([2/1024:4/1024:4],[2/1024:4/1024:4],gather(log(slice_2d))); colorbar; axis('image');
                %             xlabel('$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20);
                %             ylabel('$Y(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20);
                %             set(gca,'FontName','FixedWidth');
                %             set(gca,'FontSize',16);
                %             set(gca,'linewidth',2);
                
%             end
            
            list{count}=filename_nowake;
            count=count+1;
            %             fclose(fid);
            
            end
            
        end
        
    end
    
    
    
end


%labels

label_numbers_path='/home/asus/Dropbox/extras/storage/graham/ht/data_cps32_1024_2a3dcurvfilt_all/';
label_number=dlmread(strcat(label_numbers_path,'curvfilt2a3d_label.txt'));
label_numbers_statistics=dlmread(strcat(label_numbers_path,'curvfilt2a3d_label_numbers_statistics.txt'));


sum_label_number=sum(label_number);
number_of_nowake=320;

aug_wake=floor(number_of_nowake/sum_label_number);

list_nowake=list(1:number_of_nowake);
list_wake=list(logical(label_number));
list_eq=[list_nowake,repmat(list_wake,[1 aug_wake])];
label_number_eq=[zeros(number_of_nowake,1);ones(sum_label_number*aug_wake,1)];


list_impro=[list(1:number_of_nowake),list(logical(label_number))];
label_number_impro=[zeros(320,1);ones(sum_label_number,1)];

label= categorical(abs(double(label_number)));
label_impro= categorical(abs(double(label_number_impro)));
label_eq = categorical(abs(double(label_number_eq)));


% label= categorical(abs(double(contains(list,'nowake'))-1));
%  imds = imageDatastore(list,'ReadFcn',@read_slices_bin,'FileExtensions','.bin','Labels',label);

%load datastore

% imds = imageDatastore(list,'ReadFcn',@read_slices_bin,'FileExtensions','.bin','Labels',label);
% imds = imageDatastore(list_impro,'ReadFcn',@read_slices_bin,'FileExtensions','.bin','Labels',label_impro);
%imds = imageDatastore(list_eq,'ReadFcn',@read_slices_bin,'FileExtensions','.bin','Labels',label_eq);
imds = imageDatastore(list_eq,'Labels',label_eq);
labelCount = countEachLabel(imds);
img = readimage(imds,1);
size(img);

% figure; imshow(readimage(imds,1));

% numTrainFiles = labelCount{2,2};
% numTrainFiles = ceil(sum_label_number/2);
% numTrainFiles = 50;
% [imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.6,'randomized');

% figure; imshow(readimage(imds,1));


imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[0,360], ...
    'RandXReflection',1,...
    'RandYReflection',1);
%     'RandScale',[2 2],...
%     'RandXTranslation',[]);

auimdsTrain = augmentedImageDatastore([1024 1024],imdsTrain,'DataAugmentation',imageAugmenter);
auimdsValidation = augmentedImageDatastore([1024 1024],imdsValidation,'DataAugmentation',imageAugmenter);

% auimdsTrain = augmentedImageDatastore([224 224],imdsTrain,'ColorPreprocessing','gray2rgb');
% auimdsValidation = augmentedImageDatastore([224 224],imdsValidation,'ColorPreprocessing','gray2rgb');


% %display data
% 
% data = readByIndex(auimdsTrain,2);
% figure; imshow(cell2mat(data{1:1,{'input'}}));

% Define the convolutional neural network architecture

% layers = [
% imageInputLayer([1024 1024 3])
% convolution2dLayer(4,8,'Padding','same')
% batchNormalizationLayer
% reluLayer
% convolution2dLayer(4,8,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(4,8,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(8,16,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(16,32,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(16,32,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(32,64,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% fullyConnectedLayer(128)
% fullyConnectedLayer(64)
% fullyConnectedLayer(2)
% softmaxLayer
% classificationLayer];

% layers = [
%     imageInputLayer([1024 1024 3])
%     
%     convolution2dLayer(3,8,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     maxPooling2dLayer(2,'Stride',2)
%     
%     convolution2dLayer(3,16,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     maxPooling2dLayer(2,'Stride',2)
%     
%     convolution2dLayer(3,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     convolution2dLayer(3,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     fullyConnectedLayer(2)
%     softmaxLayer
%     classificationLayer];
% 
%  layers = [
% imageInputLayer([1024 1024 3])
% convolution2dLayer(2,1,'Padding','same')
% batchNormalizationLayer
% reluLayer
% convolution2dLayer(2,2,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(4,4,'Padding','same')
% batchNormalizationLayer
% reluLayer
% convolution2dLayer(4,8,'Padding','same')
% batchNormalizationLayer
% maxPooling2dLayer(2,'Stride',2)
% reluLayer
% convolution2dLayer(8,8,'Padding','same')
% batchNormalizationLayer
% reluLayer
% convolution2dLayer(8,16,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(16,16,'Padding','same')
% batchNormalizationLayer
% reluLayer
% convolution2dLayer(16,32,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(32,32,'Padding','same')
% batchNormalizationLayer
% reluLayer
% convolution2dLayer(32,64,'Padding','same')
% batchNormalizationLayer
% reluLayer
% % maxPooling2dLayer(2,'Stride',2)
% % convolution2dLayer(64,64,'Padding','same')
% % batchNormalizationLayer
% % reluLayer
% % convolution2dLayer(64,128,'Padding','same')
% % batchNormalizationLayer
% % reluLayer
% % maxPooling2dLayer(2,'Stride',2)
% fullyConnectedLayer(256)
% fullyConnectedLayer(256)
% fullyConnectedLayer(64)
% fullyConnectedLayer(2)
% softmaxLayer
% classificationLayer];

% see the image

% figure; imshow(readimage(imds,1));

layers = [
imageInputLayer([1024 1024 3])
convolution2dLayer(2,1,'Padding','same')
batchNormalizationLayer
reluLayer
convolution2dLayer(2,2,'Padding','same')
batchNormalizationLayer
reluLayer
maxPooling2dLayer(2,'Stride',2)
convolution2dLayer(4,4,'Padding','same')
batchNormalizationLayer
reluLayer
convolution2dLayer(4,8,'Padding','same')
batchNormalizationLayer
maxPooling2dLayer(2,'Stride',2)
reluLayer
convolution2dLayer(8,8,'Padding','same')
batchNormalizationLayer
reluLayer
convolution2dLayer(8,16,'Padding','same')
batchNormalizationLayer
reluLayer
maxPooling2dLayer(2,'Stride',2)
convolution2dLayer(16,16,'Padding','same')
batchNormalizationLayer
reluLayer
convolution2dLayer(16,32,'Padding','same')
batchNormalizationLayer
reluLayer
maxPooling2dLayer(2,'Stride',2)
convolution2dLayer(32,32,'Padding','same')
batchNormalizationLayer
reluLayer
convolution2dLayer(32,64,'Padding','same')
batchNormalizationLayer
reluLayer
maxPooling2dLayer(2,'Stride',2)
% convolution2dLayer(64,64,'Padding','same')
% batchNormalizationLayer
% reluLayer
% convolution2dLayer(64,128,'Padding','same')
% batchNormalizationLayer
% reluLayer
% maxPooling2dLayer(2,'Stride',2)
fullyConnectedLayer(256)
fullyConnectedLayer(256)
fullyConnectedLayer(64)
fullyConnectedLayer(2)
softmaxLayer
classificationLayer];





% %or
% 
% inputSize = imdsTrain.SequenceDimension;
% numClasses = imdsTrain.NumClasses;
% numHiddenUnits = 100;
% 
% layers = [ ...
%     sequenceInputLayer(inputSize)
%     lstmLayer(numHiddenUnits,'OutputMode','last')
%     fullyConnectedLayer(numClasses)
%     softmaxLayer
%     classificationLayer];

%minibatch size

miniBatchSize=2;

%Specify Training Options

options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',auimdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');
%Train Network Using Training Data


net = trainNetwork(auimdsTrain,layers,options);

YPred = classify(net,auimdsValidation,'MiniBatchSize',miniBatchSize);
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation)/numel(YValidation)

end




