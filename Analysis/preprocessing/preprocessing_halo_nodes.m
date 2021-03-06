function [ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos mass Radiusd halos] = preprocessing_halo_nodes( path,spec,aux_path,filename)
%   This function takes the halo data output from CUBEP3M and returns
%   some relevant information plus the global positions of all halos at the
%   corresponding redshift and node volume


%(example) [ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos mass Radiusd halos] = preprocessing_halo_nodes('/home/asus/Dropbox/extras/storage/','40Mpc_192c_96p_zi65_nowakes','/','0.000halo0.dat')
%(example) [ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos mass Radiusd halos] = preprocessing_halo_nodes('/gs/project/smj-701-aa/disrael/cubep3m/simulations/','64Mpc_1024c_512p_zi63_nowakem','/sample0001/','0.000halo0.dat')
%   Detailed explanation:

%reads the specifications and extract the information on variables
spec_arr = strsplit(spec,'_');

%extract the box size

size_box = spec_arr(1);
size_box = char(size_box);
size_box = size_box(1:end-3);
size_box = str2num(size_box);

%extract the number of cells per dimension

nc = spec_arr(2);
nc = char(nc);
nc = nc(1:end-1);
nc = str2num(nc);

%extract the number of particle per dimension

np = spec_arr(3);
np = char(np);
np = np(1:end-1);
np = str2num(np);
 
%extract the initial redshift of the simulation
  
 zi = spec_arr(4);
 zi = char(zi);
 zi = zi(3:end);
 zi = str2num(zi);
 
  %extracts the redshift of the file to be analised
 
 z=char(filename);
 z=str2num(z(1:end-9));
 
 % extracts the informations of the wake if there is one
 
 wake_spec = spec_arr(5);
 wake_spec = char(wake_spec);
 if wake_spec(1)=='n'
    wake_or_no_wake='no wake';
    multiplicity_of_files=wake_spec(end); 
    Gmu=0;
    ziw=0;
 end
 if wake_spec(1)=='w'
     wake_or_no_wake='wake';
     wake_spec2=strsplit(wake_spec,{'u','t10m','zi'},'CollapseDelimiters',true);
     Gmu=str2num(char(wake_spec2(2)))*10^(-str2num(char(wake_spec2(3))));
     ziw=char(wake_spec2(4));
     ziw=str2num(ziw(1:end-1));
     multiplicity_of_files=char(wake_spec(end));
 end
 
 %extract the information of the multiplicity of the files to be analysed
 
 if multiplicity_of_files=='s'
     path_file_in=strcat(path,spec,aux_path,filename);
 end
 if multiplicity_of_files=='m'
     path_file_in=strcat(path,spec,aux_path,filename);
 end
 
fid = fopen(path_file_in);
directory = dir(path_file_in);
% files_list = dir(strcat(path,spec,aux_path,'*PID0.dat'));
fread(fid,1, 'int32','l');

% if length(files_list) > 0
    



% else
%     halos=(directory.bytes-4)/(4*28);
% data=fread(fid,[28 halos], 'float32','l');
% 
% end

     halos=(directory.bytes-4)/(4*422);
     data=fread(fid,[422 halos], 'float32','l');

 if(~isempty(data))
     


Pos = data(4:6,:);
%Pos=transpose(Pos);
%Pos=mod(Pos,nc);

Radiusd= data(16,:);
%Radiusd=transpose(Radiusd);


%the mass is in grid units
mass=data(17,:);
%the mass in particle units
mass=mass*(np/nc)^3;

%mass=transpose(mass);
 
%in this part we will get the position of the wake taking into acount the
%node structure

 node=char(filename);
 node=str2num(node(strfind(filename, 'halo')+4:strfind(filename,'.dat')-1));
%  [ nodes_list redshift_list ] = preprocessing_many_nodes(path,spec,aux_path);
 [~,redshift_list,nodes_list,~,~,~,~,~,~,~,~] = preprocessing_info(path,spec,aux_path );

 number_node_dim=nthroot(numel(nodes_list), 3);
 k_node=floor(node/number_node_dim^2);
 res=mod(node,number_node_dim^2);
 j_node=floor(res/number_node_dim);
 i_node=mod(res,number_node_dim);
 
%  
%  Pos(1,:)=Pos(1,:)+(nc/number_node_dim)*i_node;
%  Pos(2,:)=Pos(2,:)+(nc/number_node_dim)*j_node;
%  Pos(3,:)=Pos(3,:)+(nc/number_node_dim)*k_node;
%  
 
%  XM=nc;
%  Xm=0;
%  YM=nc;
%  Ym=0;
%  ZM=nc;
%  Zm=0;
%  ncx=nc;
%  ncy=nc;
%  ncz=nc;
%  halfx=(XM+Xm)/2;
%  halfy=(YM+Ym)/2;
%  halfz=(ZM+Zm)/2;
%  limxinf=halfx-percentage_analysed*ncx/2;
%  limxsup=halfx+percentage_analysed*ncx/2;
%  limyinf=halfy-percentage_analysed*ncy/2;
%  limysup=halfy+percentage_analysed*ncy/2;
%  limzinf=halfz-percentage_analysed*ncz/2;
%  limzsup=halfz+percentage_analysed*ncz/2;
%  conditionsx=Pos(:,1)<=limxinf|Pos(:,1)>=limxsup;
%  conditionsy=Pos(:,2)<=limyinf|Pos(:,2)>=limysup;
%  conditionsz=Pos(:,3)<=limzinf|Pos(:,3)>=limzsup;
%  conditions=conditionsx|conditionsy|conditionsz;
%  Pos(conditions,:)=[];

 else
 
 Pos=[0;0;0];
 mass=0;
 Radiusd=0;
 halos=0;
 
end
end

%  clearvars
% Pos=[];
% for node=1:64
% filename=strcat('3.000halo',num2str(node-1),'.dat')
% [ size_box, nc, np, zi, wake_or_no_wake ,multiplicity_of_files ,Gmu ,ziw ,z, path_file_in, Pos_n, mass, Radiusd ] = preprocessing_halo_nodes( '/home/asus/Dropbox/extras/storage/graham/ht/','4Mpc_2048c_1024p_zi63_wakeGmu1t10m7zi10m','/sample3001/half_lin_cutoff_half_tot_pert_nvpw/',filename);
% Pos=[Pos Pos_n];
% end
% %Pos_old=Pos;
% %Pos=mod(Pos,nc);
% figure;

