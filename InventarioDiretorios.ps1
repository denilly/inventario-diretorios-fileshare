<#
Script PowerShell
---------------------------------------------------------------------------------
Nome: InventarioDiretorios.ps1

Descrição:
Este script realiza o inventário de pastas em um compartilhamento de rede (UNC),
exportando a estrutura para CSV e calculando o volume total do diretório.

Funcionalidades:
• Leitura recursiva da árvore de diretórios
• Suporte a caminhos longos (\\?\UNC\)
• Exportação das pastas para CSV (caminho, criação e modificação)
• Registro de erros de leitura (quando houver)
• Cálculo do volume total com Robocopy (valor equivalente ao Explorer)

Compatibilidade:
• Windows
• PowerShell 5.1 ou superior

Autor:
Denilly Carvalho do Carmo

Versão:
1.0

Uso:
1. Defina o caminho UNC:
   $caminho = "\\servidor\compartilhamento\pasta"

2. Execute:
   .\InventarioDiretorios.ps1

Saídas:
• pastas.csv → lista de diretórios
• erros.txt → gerado apenas se houver falhas

Observações:
• Pode levar tempo em pastas grandes
• Requer permissão de leitura no compartilhamento
• O volume é calculado via Robocopy para maior precisão

---------------------------------------------------------------------------------
#>

$erros = @()

#  1. =========== CONFIGURAÇÕES GERAIS - AJUSTE AS LINHAS COM "<--" CONFORME AMBIENTE ===========
# Informe o Caminho UNC (normal)
$caminho = "\\servidor\compartilhamento\pasta" # <--

# ----------------------------------------------------------------------------------------------
# NÃO ALTERE A PARTIR DAQUI!!!
# ----------------------------------------------------------------------------------------------

# 2. ==================== EXECUÇÃO PRINCIPAL DO SCRIPT ====================
# Converte automaticamente para caminho longo (\\?\UNC\)
$caminhoLongo = if ($caminho -match '^\\\\') {
    "\\?\UNC\" + $caminho.TrimStart('\')
} else {
    $caminho
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Iniciando leitura da árvore de diretórios..." -ForegroundColor Yellow
Write-Host "Caminho: $caminho"
Write-Host "=============================================`n" -ForegroundColor Cyan

Write-Host "Aguarde, isso pode levar vários minutos..."

try {
    # Exporta pastas (com suporte a caminho longo)
    Get-ChildItem $caminhoLongo -Recurse -Directory -ErrorVariable erros -ErrorAction SilentlyContinue |
    Select FullName, CreationTime, LastWriteTime |
    Export-Csv "pastas.csv" -Delimiter "|" -NoTypeInformation -Encoding UTF8

    # Calcula volume real com Robocopy (não copia nada)
    Write-Host "`nCalculando volume total..." -ForegroundColor Yellow

    $saida = robocopy $caminho NULL /E /L /BYTES /NFL /NDL

    # Captura a linha que contém "Bytes"
    $linhaBytes = $saida | Where-Object { $_ -match "^\s*Bytes:" }

    if ($linhaBytes) {
        # Extrai apenas o primeiro número após "Bytes:"
        if ($linhaBytes -match "Bytes:\s+([0-9]+)") {
            $totalBytes = [double]$matches[1]
        } else {
            $totalBytes = 0
        }
    } else {
        $totalBytes = 0
    }

    $totalGB = [math]::Round(($totalBytes / 1GB), 2)

    # Tratamento de erros de diretório
    if ($erros.Count -gt 0) {
        Write-Host "`nProcesso concluído COM ALERTAS." -ForegroundColor Yellow
        Write-Host "Algumas pastas não puderam ser lidas."
        $erros | Out-File "erros.txt"

        Write-Host "Arquivo gerado: pastas.csv"
        Write-Host "Log de erros: erros.txt"
    }
    else {
        Write-Host "`nProcesso concluído com SUCESSO!" -ForegroundColor Green
        Write-Host "Arquivo gerado: pastas.csv"
    }

    # Resultado final confiável
    Write-Host "`nVolume total do diretório: $totalGB GB" -ForegroundColor Cyan
}
catch {
    Write-Host "`nERRO CRÍTICO durante a execução!" -ForegroundColor Red
    Write-Host $_
}

Write-Host "`nPressione qualquer tecla para fechar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")