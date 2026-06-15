Set-Location -Path $PSScriptRoot

# Define os parametros do Grafo
$nNodes = 50000

# Calcula automaticamente o grafo mais denso (60% dos nos)
$nEdges = [math]::Floor($nNodes * 0.60)
$seed = 42

# Define a quantidade de repeticoes do teste
$numExecucoes = 5

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Iniciando Benchmark Dijkstra (${nNodes} vertices ${nEdges} arestas)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Compilacao
Write-Host ""
Write-Host "[1/3] Compilando os programas..." -ForegroundColor Yellow
gcc dijkstra.c -o dijkstra_seq.exe
gcc dijkstra_openMP.c -fopenmp -o dijkstra_openmp.exe

# Variaveis para expressoes regulares
$regexTempo = 'Tempo:\s*([0-9.]+)'
$regexMedia = '^([0-9.]+)'
$cultura = [System.Globalization.CultureInfo]::InvariantCulture

# Acumuladores de tempo e controle
$somaTempoSeq = 0.0
$somaTempoOpenMP = 0.0
$mediaDistanciaReferencia = $null

# 2. Execucao Sequencial
Write-Host ""
Write-Host "[2/3] Executando versao Sequencial (Baseline)..." -ForegroundColor Yellow

for ($i = 1; $i -le $numExecucoes; $i++) {
    $outSeq = .\dijkstra_seq.exe $nNodes $nEdges $seed
    
    $strTempoSeq = [regex]::Match($outSeq, $regexTempo).Groups[1].Value
    $strMediaSeq = [regex]::Match($outSeq, $regexMedia).Groups[1].Value
    
    # Salva a distancia da primeira execucao para usar de gabarito
    if ($i -eq 1) { $mediaDistanciaReferencia = $strMediaSeq }
    
    $tempoSeq = [double]::Parse($strTempoSeq, $cultura)
    $somaTempoSeq += $tempoSeq
    
    Write-Host "  -> Iteracao ${i}/${numExecucoes} : ${tempoSeq} segundos" -ForegroundColor DarkGray
}

# 3. Execucao Paralela
Write-Host ""
Write-Host "[3/3] Executando versao Paralela (OpenMP)..." -ForegroundColor Yellow

for ($i = 1; $i -le $numExecucoes; $i++) {
    $outPar = .\dijkstra_openmp.exe $nNodes $nEdges $seed
    
    $strTempoPar = [regex]::Match($outPar, $regexTempo).Groups[1].Value
    $strMediaPar = [regex]::Match($outPar, $regexMedia).Groups[1].Value
    
    # Validacao rigorosa de integridade
    if ($strMediaPar -ne $mediaDistanciaReferencia) {
        Write-Host "  [AVISO CRITICO] A iteracao ${i} falhou na validacao matematica!" -ForegroundColor Red
    }
    
    $tempoPar = [double]::Parse($strTempoPar, $cultura)
    $somaTempoOpenMP += $tempoPar
    
    Write-Host "  -> Iteracao ${i}/${numExecucoes} : ${tempoPar} segundos" -ForegroundColor DarkGray
}

# 4. Calculos Finais
$mediaTempoSeq = $somaTempoSeq / $numExecucoes
$mediaTempoOpenMP = $somaTempoOpenMP / $numExecucoes
$speedupOpenMP = $mediaTempoSeq / $mediaTempoOpenMP

# Arredondamentos
$strMediaTempoSeq = [math]::Round($mediaTempoSeq, 4)
$strMediaTempoOpenMP = [math]::Round($mediaTempoOpenMP, 4)
$strSpeedupOpenMP = [math]::Round($speedupOpenMP, 2)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " RELATORIO FINAL DE SPEEDUP (MEDIA DE ${numExecucoes} EXECUCOES)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Tempo Sequencial : ${strMediaTempoSeq} segundos (1.00x)" -ForegroundColor Gray
Write-Host "Tempo Paralelo (openMP)   : ${strMediaTempoOpenMP} segundos (Speedup: ${strSpeedupOpenMP}x)" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan