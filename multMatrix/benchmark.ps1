# Define o tamanho da matriz
$N = 2000

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Iniciando Benchmark Completo ($N x $N)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Compilação
Write-Host "`n[1/4] Compilando os programas..." -ForegroundColor Yellow
gcc multMatrixSequencial.c -o sequencial.exe
gcc multMatrixEstatica.c -fopenmp -o estatica.exe
gcc multMatrixDinamica.c -fopenmp -o dinamica.exe

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro na compilacao. Verifique os nomes dos arquivos. Abortando." -ForegroundColor Red
    exit
}

# 2. Execucao
Write-Host "[2/4] Executando versao Sequencial (Baseline)..." -ForegroundColor Yellow
$outSeq = .\sequencial.exe $N
Write-Host " -> $outSeq" -ForegroundColor Green

Write-Host "[3/4] Executando versao Estatica (OpenMP)..." -ForegroundColor Yellow
$outEst = .\estatica.exe $N
Write-Host " -> $outEst" -ForegroundColor Green

Write-Host "[4/4] Executando versao Dinamica (OpenMP)..." -ForegroundColor Yellow
$outDin = .\dinamica.exe $N
Write-Host " -> $outDin" -ForegroundColor Green

# 3. Extracao dos tempos usando Expressao Regular (Regex)
$regex = '([0-9.]+)'
$strSeq = [regex]::Match($outSeq, $regex).Value
$strEst = [regex]::Match($outEst, $regex).Value
$strDin = [regex]::Match($outDin, $regex).Value

# Converte os textos extraidos para numeros reais (Double)
$cultura = [System.Globalization.CultureInfo]::InvariantCulture
$tempoSeq = [double]::Parse($strSeq, $cultura)
$tempoEst = [double]::Parse($strEst, $cultura)
$tempoDin = [double]::Parse($strDin, $cultura)

# 4. Calculo de Speedup (Tempo Sequencial / Tempo Paralelo)
$speedupEst = $tempoSeq / $tempoEst
$speedupDin = $tempoSeq / $tempoDin

# Arredonda os valores para exibicao (2 casas decimais)
$strSpeedupEst = [math]::Round($speedupEst, 2)
$strSpeedupDin = [math]::Round($speedupDin, 2)

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host " RELATORIO FINAL DE SPEEDUP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Tempo Sequencial (Sem OpenMP): $tempoSeq segundos (1.00x)" -ForegroundColor Gray
Write-Host "Tempo Estatica   (Com OpenMP): $tempoEst segundos (Speedup: ${strSpeedupEst}x)" -ForegroundColor White
Write-Host "Tempo Dinamica   (Com OpenMP): $tempoDin segundos (Speedup: ${strSpeedupDin}x)" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan