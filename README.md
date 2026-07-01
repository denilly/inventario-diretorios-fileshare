# 📂 Inventário de Diretórios em Fileshare (PowerShell)

## 📌 Descrição

Script em PowerShell para inventário de diretórios em compartilhamentos de rede (SMB/UNC), com exportação da estrutura de pastas para CSV e cálculo do volume total com alta precisão.

O volume é calculado utilizando **Robocopy em modo simulação**, garantindo resultado equivalente ao exibido nas propriedades da pasta no Windows Explorer.

---

## ⚙️ Funcionalidades

- 📁 Leitura recursiva de diretórios
- 🧾 Exportação da estrutura de pastas para CSV
- 🕒 Registro de datas (criação e última modificação)
- 🧠 Suporte a caminhos longos (`\\?\UNC\`)
- ⚠️ Tratamento de erros de leitura (permissões, inconsistências)
- 📦 Cálculo preciso do volume total do diretório
- 💬 Feedback de execução no console

---

## 🧱 Requisitos

- Windows
- PowerShell 5.1 ou superior
- Acesso ao compartilhamento de rede (UNC)
- Permissão de leitura nas pastas

---

## ▶️ Como usar

### 1. Executar informando o caminho via parâmetro

```powershell
.\InventarioDiretorios.ps1 -caminho "\\servidor\compartilhamento\pasta"
````

ou

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\InventarioDiretorios.ps1 -caminho "\\servidor\compartilhamento\pasta"
```

***

### 2. Executar sem parâmetros (modo interativo)

```powershell
.\InventarioDiretorios.ps1
```

ou

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\InventarioDiretorios.ps1
```

Ao iniciar sem o parâmetro `-caminho`, o script solicitará que o usuário informe o caminho UNC desejado:

```text
Informe o caminho do diretório (UNC):
Exemplo: \\servidor\compartilhamento\pasta
```


***

## 📁 Saídas geradas

| Arquivo      | Descrição                                 |
| ------------ | ----------------------------------------- |
| `pastas.csv` | Lista de diretórios com metadados         |
| `erros.txt`  | Gerado apenas se houver falhas de leitura |

***

## 📊 Estrutura do CSV

Colunas exportadas:

* `FullName` → Caminho completo da pasta
* `CreationTime` → Data de criação
* `LastWriteTime` → Data de última modificação

Separador: `|` (pipe), evitando conflitos com nomes de arquivos.

***

## 📦 Cálculo de volume

O volume total é obtido com:

```bash
robocopy origem NULL /E /L /BYTES /NFL /NDL
```

### ✅ Por que usar Robocopy?

* Maior precisão que `Get-ChildItem`
* Melhor compatibilidade com NAS
* Tolerante a erros de leitura
* Equivalente ao valor exibido no Explorer

***

## ⚠️ Limitações

* Pastas sem permissão não são listadas
* Arquivos inacessíveis podem impactar parcialmente o volume
* Execução pode ser lenta em diretórios grandes
* Pequenas diferenças podem ocorrer com arquivos em uso

***

## ✅ Boas práticas

* Utilizar caminhos UNC (evitar unidades mapeadas)
* Executar com permissões adequadas
* Evitar uso em horários de pico da rede
* Testar inicialmente em subpastas menores

***

## 📌 Exemplo de saída

```
Processo concluído com SUCESSO!
Arquivo gerado: pastas.csv
Volume total do diretório: 3266.08 GB
```

***

## 🧠 Contexto técnico

O script utiliza duas abordagens:

* ✅ `\\?\UNC\` → leitura de pastas com suporte a caminhos longos
* ✅ `Robocopy` → cálculo confiável de volume

Essa combinação garante maior compatibilidade com ambientes de rede corporativos e storages/NAS.

***

## 👨‍💻 Autor

**Denilly Carvalho do Carmo**

***

## 📄 Licença

Este projeto está licenciado sob os termos da:

**GNU General Public License v3.0 (GPL-3.0)**

***

## 🤝 Contribuição

Sugestões e melhorias são bem-vindas.  
Sinta-se à vontade para abrir issues ou pull requests.

***

## ⭐ Observação

Este script foi desenvolvido para ambientes corporativos com:

* Compartilhamento de arquivos (SMB/NAS)
* Estruturas complexas de diretórios
* Caminhos longos e permissões heterogêneas

Sendo ideal para:

* auditoria de storage
* organização de repositórios
* análises de ocupação de dados

***
