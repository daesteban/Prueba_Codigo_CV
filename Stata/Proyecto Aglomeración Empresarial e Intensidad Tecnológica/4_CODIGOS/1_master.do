clear all
cls
*****************************************************************
global codigo "D:\STATA LIMPIO\4_CODIGOS"
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
*****************************************************************
//Limpieza de datos de la Encuesta Economica Anual 2014-2018
cd "$codigo"
do "baseD2_2018.do" 
do "baseD2_2017.do" 
do "baseD2_2016.do" 
do "baseD2_2015.do" 
do "baseD2_2014.do" 
do "baseM_2018.do" 
do "baseM_2017.do" 
do "baseM_2016.do" 
do "baseM_2015.do" 
do "baseM_2014.do" 

//Juntamos todos las bases de datos intermedios en una sola base de datos
do "2_merging_data.do"

*****************************************************************
//REGRESIONES Y TABLAS
do "3_output_y_regresiones.do"




