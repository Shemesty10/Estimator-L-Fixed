Tugas 1 ADSPD untuk Estimator
clc
clear all

% Sementara Nilai Matriks State Space Continous
Matriks_A_Continous = [0 1 0;
            0 0 1;
            -6 -11 -6];
Matriks_B_Continous = [0 0 1]';
Matriks_C_Continous = [20 9 1];
Matriks_D_Continous = [];
Sistem_Continous = ss(Matriks_A_Continous,Matriks_B_Continous,Matriks_C_Continous,Matriks_D_Continous);

% Mengubah Nilai Matriks State Space ke Diskrit
Sistem_Diskrit = c2d(Sistem_Continous,0.6);
Matriks_A_Diskrit = Sistem_Diskrit.A;
Matriks_B_Diskrit = Sistem_Diskrit.B;
Matriks_C_Diskrit = Sistem_Diskrit.C;
Matriks_D_Diskrit = Sistem_Diskrit.D;

Observability_Matriks = obsv(Matriks_A_Diskrit,Matriks_C_Diskrit);
Rank_Observability = rank(Observability_Matriks);

if (Rank_Observability == length(Matriks_C_Diskrit))
    disp('Sistem Observable')
end


%% Karena Sistem Observable, Kita mulai mencoba membuat Estimator
% Memanggil Data

Import_Data = importdata('DataUntukTugas1.mat');

Data_Input_Diskrit = Import_Data.Nilai_Input_Diskrit.signals.values;
Data_Output_Diskrit = Import_Data.Nilai_Output_Diskrit.signals.values;
Data_State_1_Diskrit = Import_Data.State_1_Diskrit.signals.values;

% Estimator state x2 dan x3
% inisiasi estimasi x2 dan x3 serta x1

Toleransi_Error = 0.05;
Matriks_L_Estimator = [1; -0.0015; 0.0025];

State_x1 = Data_State_1_Diskrit;
State_x2(1) = abs(randn);
State_x3(1) = abs(randn);

State_x(:,1) = [State_x1(1); State_x2(1); State_x3(1)];

for i = 1 : length(Data_Output_Diskrit)

    Data_Output_Estimasi(i) = Matriks_C_Diskrit*State_x(:,i);
    Error_Output_Estimasi(i) = Data_Output_Diskrit(i) - Data_Output_Estimasi(i);

    while abs(Error_Output_Estimasi(i)) > Toleransi_Error

        State_x_Estimasi(:,i) = Matriks_A_Diskrit*State_x(:,i) + Matriks_B_Diskrit*Data_Input_Diskrit(i) + Matriks_L_Estimator*Error_Output_Estimasi(i);
        State_x(:,i) = [State_x1(i); State_x_Estimasi(2,i); State_x_Estimasi(3,i)];
        Data_Output_Estimasi(i) = Matriks_C_Diskrit*State_x(:,i);
        Error_Output_Estimasi(i) = Data_Output_Diskrit(i) - Data_Output_Estimasi(i);

    end

    n = i + 1;
    if n > length(Data_Output_Diskrit)
        break;
    end
    State_x_Estimasi(:,n) = Matriks_A_Diskrit*State_x(:,i) + Matriks_B_Diskrit*Data_Input_Diskrit(i) + Matriks_L_Estimator*Error_Output_Estimasi(i);
    State_x(:,n) = [State_x1(n); State_x_Estimasi(2,n); State_x_Estimasi(3,n)];

end

%% End of Estimator - Plotting

Sumbu_x = linspace(0,30,length(Data_Input_Diskrit));

figure(1)
subplot(1,2,1);
stairs(Sumbu_x,Data_Output_Diskrit,"r");
xlim([0 30])
legend('Data Output Sebenarnya')
grid on

subplot(1,2,2);
stairs(Sumbu_x,Data_Output_Estimasi');
xlim([0 30])
legend('Data Output Estimator')
grid on

figure(2)
stairs(Sumbu_x,State_x(1,:));
hold on 
stairs(Sumbu_x,State_x(2,:));
stairs(Sumbu_x,State_x(3,:));
xlim([0 30])
legend('State_ x1','State_ x2','State_ x3')
grid on

MSE_Estimator_Real = immse(Data_Output_Estimasi',Data_Output_Diskrit)