function [  ] = box_statistics_halos_per_node( root,root_out,spec,aux_path,aux_path_out,NSIDE,node ,num_cores)
    
%(example) box_statistics_halos_per_node('/home/asus/Dropbox/extras/storage/', '/home/asus/Dropbox/extras/storage/','40Mpc_192c_96p_zi65_nowakes','/','',4,0,4);
%(example) box_statistics_halos_per_node('/home/asus/Dropbox/extras/storage/guillimin/old/','/home/asus/Dropbox/extras/storage/guillimin/old/','32Mpc_96c_48p_zi63_nowakes','/','',4,0,4);

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


pivot=[0,0,0]; %this is the position od the origin of the rotation point with respect to the center of the box
lenght_factor=2;
resol_factor=2;


p = parpool(num_cores);
tic;

path_in=strcat(root,spec,aux_path);
files_list = dir(strcat(path_in,'*halo',num2str(node),'.dat'));
sorted_files_list={files_list.name};

cd('../../processing');

sorted_files_list=sort_nat(sorted_files_list);

%display(sorted_files_list)

cd('../preprocessing');

angles = dlmread(strcat('../../python/angles',num2str(NSIDE),'.txt'));
[angle_nuple,number_of_angle_nuple] = size(angles);

number_of_redshifts=length(sorted_files_list);

mkdir(root_out);
mkdir(root_out,strcat(spec,aux_path));


%for k = 3:-1:1
for k = 1  :   length(sorted_files_list)
%for k = 1  : 1
    
    cd('../preprocessing');
    
    %proj=[];
    
    filename=char(sorted_files_list(k));
    
    [ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos mass Radiusd halos] = preprocessing_halo_nodes(root,spec,aux_path,filename);
%     [ size_box nc zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos ] = preprocessing_nodes( path,spec,aux_path,filename,1.0);
%    if (halos~=0)

    mass=mass*(np/nc)^3;


    Pos=mod(Pos,nc);
    
    [m n] = size(Pos);
    
    int_div=fix(n/num_cores);
     
    for i=1:num_cores+1
        counter(i)=((i-1)*int_div);
    end
        counter(num_cores+2)=n;
        
%        Pos=transpose(Pos);
    
    bins=[-(nc/(2*lenght_factor)):nc/(np*resol_factor):(nc/(2*lenght_factor))];
    
   count_sum_h_number=zeros(number_of_angle_nuple,length(bins)-1);
   count_sum_h_mass=zeros(number_of_angle_nuple,length(bins)-1);

    
    parfor i=1:number_of_angle_nuple
%     for i=1:number_of_angle_nuple
 %   for i=1:1
         

         
        theta=angles(1,i);
        phi=angles(2,i);
        
        hist1d_cor=zeros(1,length(bins)-1);
        hist1d_cor_mass=zeros(1,length(bins)-1);
        
       for j=1:num_cores+1
       % for j=1:1000
       
       rx=[];
       mass_aux=[];
        
        rx(1,:)=Pos(1,counter(j)+1:counter(j+1))-(nc/2)-pivot(1);
        rx(2,:)=Pos(2,counter(j)+1:counter(j+1))-(nc/2)-pivot(2);
        rx(3,:)=Pos(3,counter(j)+1:counter(j+1))-(nc/2)-pivot(3);
        
        %display(size(mass_aux));
       % display(size(mass));
        
        mass_aux(1,:)=mass(1,counter(j)+1:counter(j+1));
        
      %  display(size(mass_aux));



        Ry = [cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
        Rz = [cos(phi) -sin(phi) 0; sin(phi) cos(phi) 0; 0 0 1]; 
%         
        rx=Rz*rx;
        rx=Ry*rx;      
        
        liminf=-(1/(2*lenght_factor))*nc;
        limsup= (1/(2*lenght_factor))*nc;
        conditionsx=rx(1,:)<=liminf|rx(1,:)>=limsup;
        conditionsy=rx(2,:)<=liminf|rx(2,:)>=limsup;
        conditionsz=rx(3,:)<=liminf|rx(3,:)>=limsup;
        conditions=conditionsx|conditionsy|conditionsz;
        rx(:,conditions)=[];
        mass_aux(conditions)=[];
        
         rx=transpose(rx);
         
         %display(rx);
         
         if(~isempty(rx))
        
        [count edges mid loc] = histcn(rx,1,1,bins);
       % display(count);
       % display(length(bins));
        count=count(1:1,1:1,1:length(bins)-1);
   %     average=mean2(count);
   %     count=(count-average)/average;
        count=squeeze(count);
        count=squeeze(count);
        
        count=transpose(count);
        
       % display(count);
        
        
        
        hist1d_cor=hist1d_cor+count;
        
       % display(hist1d_cor);
        
       
       display(size(rx));
       display(size(transpose(mass_aux)));
       
        [count_h_m edges mid loc] = histcn(rx,1,1,bins,'AccumData',transpose(mass_aux));
        count_h_m=count_h_m(1:1,1:1,1:numel(bins)-1);
        %     average=mean2(count);
        %     count=(count-average)/average;
        count_h_m=squeeze(count_h_m);
        count_h_m=squeeze(count_h_m);
        
        %    cell_bins1d(end)=[];
        hist1d_cor_mass=hist1d_cor_mass+transpose(count_h_m);  
       
        
         end
        

        end
        
       % proj=transpose(proj);
        
        %display(proj);
        
        % [proj edges mid loc] = histcn(proj,bins);
         
        
        %proj=transpose(proj);
        
       % display(size(proj1d_angles));
       % display(size(hist1d_cor));
       
        % average=mean2(hist1d_cor);
        % hist1d_cor=(hist1d_cor-average)/average;
         
         count_sum_h_number(i,:)=hist1d_cor(:);
         count_sum_h_mass(i,:)=hist1d_cor_mass(:);

        fprintf('done for z= %f and  i= %d\n',z, i);
        %display(proj);
 
    end
    
    path_out=strcat(strcat(root_out,spec,aux_path),'data/',aux_path_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv','/','stat/box_statistics/halos/');
    mkdir(strcat(root_out,spec,aux_path),strcat('data/',aux_path_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv','/','stat/box_statistics/halos/'));
    
    mkdir(path_out,'num_count_per_node_1dproj/');
    dlmwrite(strcat(path_out,'num_count_per_node_1dproj/','1dproj_angle_halos_z',num2str(z),'_node',num2str(node),'_NSIDE',num2str(NSIDE),'.txt'),count_sum_h_number,'delimiter','\t');

    mkdir(path_out,'mass_per_node_1dproj/');
    dlmwrite(strcat(path_out,'mass_per_node_1dproj/','1dproj_angle_halos_z',num2str(z),'_node',num2str(node),'_NSIDE',num2str(NSIDE),'.txt'),count_sum_h_mass,'delimiter','\t');

    
end

cd('../wake_detection/box_statistics');

toc;

delete(gcp('nocreate'))

end

