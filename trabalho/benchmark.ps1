Set-Location -Path $PSScriptRoot

# Define os parâmetros do Grafo
$nNodes = 40000

# O PowerShell calcula automaticamente o grafo mais denso e seguro possível (60% dos nós)
$nEdges = [math]::Floor($nNodes * 0.60)
$seed = 42

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Iniciando Benchmark Dijkstra ($nNodes nodes)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Compilação
Write-Host "`n[1/3] Compilando os programas..." -ForegroundColor Yellow
# Assumindo que o arquivo original se chama 'dijkstra.c' e o novo 'dijkstra_parallel.c'
gcc dijkstra.c -o dijkstra_seq.exe
gcc dijkstra_parallel.c -fopenmp -o dijkstra_par.exe

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro na compilacao. Verifique os nomes dos arquivos. Abortando." -ForegroundColor Red
    exit
}

# 2. Execução
Write-Host "[2/3] Executando versao Sequencial (Baseline)..." -ForegroundColor Yellow
$outSeq = .\dijkstra_seq.exe $nNodes $nEdges $seed
Write-Host " -> Saida Sequencial:`n$outSeq" -ForegroundColor DarkGray

Write-Host "`n[3/3] Executando versao Paralela (OpenMP)..." -ForegroundColor Yellow
$outPar = .\dijkstra_par.exe $nNodes $nEdges $seed
Write-Host " -> Saida Paralela:`n$outPar" -ForegroundColor DarkGray

# 3. Extração dos valores usando Expressão Regular (Regex)
# Captura o número que vem logo após a palavra "Tempo: "
$regexTempo = 'Tempo:\s*([0-9.]+)'
# Captura o primeiro número da saída (que é a média)
$regexMedia = '^([0-9.]+)'

$strTempoSeq = [regex]::Match($outSeq, $regexTempo).Groups[1].Value
$strMediaSeq = [regex]::Match($outSeq, $regexMedia).Groups[1].Value

$strTempoPar = [regex]::Match($outPar, $regexTempo).Groups[1].Value
$strMediaPar = [regex]::Match($outPar, $regexMedia).Groups[1].Value

# Converte os tempos extraídos para números reais (Double)
$cultura = [System.Globalization.CultureInfo]::InvariantCulture
$tempoSeq = [double]::Parse($strTempoSeq, $cultura)
$tempoPar = [double]::Parse($strTempoPar, $cultura)

# Verificação de Integridade (Valida se o OpenMP não quebrou a lógica)
if ($strMediaSeq -ne $strMediaPar) {
    Write-Host "`n[AVISO CRITICO] As distancias medias nao bateram! ($strMediaSeq vs $strMediaPar)" -ForegroundColor Red
    Write-Host "Isso indica que ha uma condicao de corrida no seu OpenMP." -ForegroundColor Red
}

# 4. Cálculo de Speedup (Tempo Sequencial / Tempo Paralelo)
$speedup = $tempoSeq / $tempoPar

# Arredonda o valor do speedup para exibição (2 casas decimais)
$strSpeedup = [math]::Round($speedup, 2)

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host " RELATORIO FINAL DE SPEEDUP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Tempo Sequencial : $tempoSeq segundos (1.00x)" -ForegroundColor Gray
Write-Host "Tempo Paralelo   : $tempoPar segundos (Speedup: ${strSpeedup}x)" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan