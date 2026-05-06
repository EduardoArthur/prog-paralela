@echo off

REM 1. Garante que a execucao ocorra dentro da pasta onde o script esta salvo
cd /d "%~dp0"

REM 2. Variaveis de Configuracao
set NUM_PROCS=4

echo ==========================================
echo  Iniciando Execucao MPI (%NUM_PROCS% processos)
echo ==========================================

echo Compilando no Windows...
gcc mpiEx1.c -o mpiEx1.exe -I"%MSMPI_INC%" -L"%MSMPI_LIB64%" -lmsmpi

IF %ERRORLEVEL% EQU 0 (
    echo Compilacao concluida com sucesso!
    echo Executando...
    echo -----------------------------------
    
    REM 3. Utiliza a variavel na chamada do mpiexec
    mpiexec -n %NUM_PROCS% mpiEx1.exe
) ELSE (
    echo Erro durante a compilacao.
)

echo.
pause