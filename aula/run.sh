#!/bin/bash

# 1. Garante que a execução ocorra dentro da pasta onde o script está salvo
cd "$(dirname "$0")"

# 2. Variáveis de Configuração
NUM_PROCS=4

# Configuração de cores (Equivalente ao -ForegroundColor Cyan)
CYAN='\033[0;36m'
NC='\033[0m' # Sem Cor

echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN} Iniciando Execução MPI ($NUM_PROCS processos)${NC}"
echo -e "${CYAN}==========================================${NC}"

echo "Compilando no Linux..."
mpicc mpiEx1.c -o mpiEx1

if [ $? -eq 0 ]; then
    echo "Compilação concluída com sucesso!"
    echo "Executando..."
    echo "-----------------------------------"
    
    # 3. Utiliza a variável na chamada do mpirun
    mpirun -np $NUM_PROCS ./mpiEx1
else
    echo "Erro durante a compilação."
fi