% CALCULATES THE IAS/TAS/MACH RELATIONSHIP AND CROSSOVER DIAGRAM
% Clean up workspace
clc; clear all; close all;
addpath('../kgbx-lib/bada');

run Constants;

% Constant CAS curves

V = [];
M = [];
SS = [];

index1=1;
for Vcas=150:25:400
    index2=1;
    for h=0:100:37000
        [Vtas,Mach]=cas2tas(Vcas*KTS2MPS,h*FT2M);
        VTAS(index1,index2)=Vtas*MPS2KTS;
        M(index1,index2)=Mach;
 
        [rho, p, temp, soundSpeed] = getAtmosphericData(h*FT2M);
        SS(index1,index2)= soundSpeed;
        index2=index2+1;
    end

    h = 0:100:37000;
    hold on; plot(VTAS(index1,:),h,'r');
    index1=index1+1;
end

%kk

% Constant Mach curves
im=1;
for Mm=0.2:0.05:1
    Mm
    index1=1;
    H=[0];
    V=[];
    for h=0:100:37000
        index2=1;
        for Vcas=10:10:900 
            [Vtas,Mach]=cas2tas(Vcas*KTS2MPS,h*FT2M);
            if (abs(Mach-Mm)<.0005)
                H=[H,h];
                V=[V,Vtas*MPS2KTS];
            end
        end
    end
    Hm{im,:}=H(2:end);
    Vm{im,:}=V;
    plot(Vm{im,:},Hm{im,:},'b'); hold on;
    im=im+1;
end

% Save
h = 0:100:37000;
Mm=0.2:0.05:1;
Vcas=150:25:400;
save('Mach','h','Vcas','VTAS','Mm','Hm','Vm');