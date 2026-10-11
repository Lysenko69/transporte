clc;
addpath('../matlab_utilities/');
addpath('../../lib-04-09-2020/kgbx-lib/geo/');
addpath('../../lib-04-09-2020/kgbx-lib/kml/');

fp=xml2struct('LFQQLEMI_XML_1729323178.xml'); %LEMDLEBL_XML_1538119110.xml');

for i= 1:9
wp(i)=fill_wp(fp,i);
end

