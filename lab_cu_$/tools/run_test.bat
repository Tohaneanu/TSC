::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
:: vsim -gui -do run.do
vsim -%5 -do "do run.do %0 %1 %2 %3 %4"
