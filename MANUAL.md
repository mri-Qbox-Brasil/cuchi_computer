# cuchi_computer — Manual

Computadores e laptops utilizáveis no jogo, com sistema operacional em NUI: console com comandos de rede, e-mail, mercado, endereços da darkweb e um assalto de dados (data heist).

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Banco de dados](#banco-de-dados)
4. [Configuração](#configuração)
5. [Como abrir um computador](#como-abrir-um-computador)
6. [Aplicativos](#aplicativos)
7. [Console — comandos](#console--comandos)
8. [Data Heist](#data-heist)
9. [Endereços](#endereços)
10. [Integrações](#integrações)
11. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
12. [Localização](#localização)
13. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `qb-core` **ou** ESX | Sim | Definido em `Config.Framework` e `Config.FrameworkResourceName`. O recurso precisa iniciar **depois** do framework |
| `oxmysql` | Sim | Tabelas de mercado e e-mail |
| `ox_target` ou `qb-target` | Não | Só se `Config.TargetSystem = true`. Com `false`, a interação com os props é por checagem de distância |

---

## Instalação

1. Copie a pasta `cuchi_computer` para `resources/`.
2. Importe o `tables.sql` (ver [Banco de dados](#banco-de-dados)).
3. Adicione ao `server.cfg`, depois do framework:
   ```
   ensure qb-core
   ensure cuchi_computer
   ```
4. Se for usar o item (padrão `laptop`, definido em `Config.UseItem`), registre-o no inventário como **usável**. Para desativar o item, deixe `Config.UseItem = ""`.
5. Ajuste `config.lua`: framework, locale, sistema de target e as posições de computadores livres.

---

## Banco de dados

O `tables.sql` cria três tabelas:

| Tabela | Conteúdo |
|---|---|
| `computers_market` | Anúncios do app Market: `seller`, `title`, `description`, `timestamp` |
| `computers_mail_accounts` | Contas de e-mail: `identifier`, `username`, `password` |
| `computers_mail_mails` | Mensagens: `from`, `to`, `object`, `text`, `answer_to`, `timestamp`, `read` |

---

## Configuração

Arquivo: `config.lua`.

### Compartilhado

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.Framework` | string | Sim | `"qbcore"` ou `"esx"` |
| `Config.FrameworkResourceName` | string | Sim | Nome do recurso do framework. Ex.: `"qb-core"` ou `"es_extended"` |
| `Config.FrameworkOptionalExportName` | string | Sim | Só preencha se você renomeou o export que devolve o objeto do core. Vazio usa `GetCoreObject` (QBCore) ou `getSharedObject` (ESX) |
| `Config.Locale` | string | Sim | Idioma da interface. `PT`, `EN`, `FR`, `ES`, `DA` ou `DE` |
| `Config.UseItem` | string | Sim | Item que abre a interface. Padrão: `laptop`. String vazia desativa o uso por item |

### Data Heist

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.DataHeists.Enabled` | bool | Sim | Liga o assalto de dados |
| `Config.DataHeists.DisplayArea` | bool | Sim | Desenha as áreas no mapa (útil para configurar) |
| `Config.DataHeists.Reward` | `{min, max}` | Sim | Recompensa sorteada entre os dois valores. Padrão: `10000` a `20000` |
| `Config.DataHeists.TypeOfDelay` | string | Sim | `"each"` = um cooldown por área; `"all"` = um cooldown global |
| `Config.DataHeists.Delay` | número (min) | Sim | Cooldown entre assaltos. Padrão: `60` |
| `Config.DataHeists.JobsToCall` | lista | Sim | Jobs que recebem o alerta com o GPS. Padrão: `police`, `sheriff` |
| `Config.DataHeists.Areas` | tabela | Sim | `[vector3] = raio em metros`. Padrão: as 5 Fleeca + o estacionamento da Arcadius (raio 50) |

### Servidor

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.Functions.GetIdentifier` | função | Sim | Devolve o identificador do jogador. Por padrão usa a `license`. Comente e use `playerObj.PlayerData.citizenid` se quiser contas de e-mail por personagem em vez de por conta |

### Cliente

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.LaptopInVehicle` | bool | Sim | Permite usar o laptop dentro de veículos |
| `Config.UseProps` | lista de hashes | Sim | Props do jogo base (laptops, computadores e monitores) que viram computadores interativos. Esvazie a lista para desativar |
| `Config.TargetSystem` | bool | Sim | `true` usa target nos props; `false` usa marker + checagem de distância |
| `Config.TargetType` | string | Sim | `"ox"` ou `"qb"` |
| `Config.UsablePositions` | lista de `vector3` | Sim | Coordenadas onde qualquer jogador pode abrir um computador livre, sem prop e sem item |
| `CustomDrawMarker` | função | Sim | Marker exibido nos pontos interativos. Sobrescreva para mudar o visual |
| `CustomHelpNotification` | função | Sim | Notificação de ajuda ("pressione E"). Sobrescreva para usar o seu sistema |
| `CustomNotification` | função | Sim | Notificação normal. Sobrescreva para usar o seu sistema |

### Aplicativos

Arquivo: `app_config.lua`.

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `AppConfig.Market.delayBetweenEachPost` | número (s) | Sim | Cooldown entre anúncios. Padrão: `600` |
| `AppConfig.Market.maxPosts` | número | Sim | Máximo de anúncios ativos por jogador. Padrão: `5` |
| `AppConfig.Market.timeBeforeAutomaticDeletion` | número (s) | Sim | Tempo até o anúncio ser apagado do banco. Padrão: 14 dias |
| `AppConfig.Mail.domain` | string | Sim | Domínio dos e-mails. Padrão neste fork: `@mriqbox.com` |
| `AppConfig.Addresses` | lista | Sim | Endereços acessíveis pelo console. Padrão: `chat.incognito.net` e `selldata.com` |
| `AppConfig.Themes` | lista | Sim | Temas de cor do sistema. Cada tema define `--main-color`, `--lighter-color`, `--darker-color`, `--darkest-color`, `--app-minimize-color` e `--app-exit-color`. O jogador escolhe pelo app Themes |

---

## Como abrir um computador

Há três caminhos, e eles funcionam juntos:

1. **Item** — usar o item de `Config.UseItem` (padrão `laptop`). Abre um laptop. Com `Config.LaptopInVehicle = true`, funciona também dentro do veículo.
2. **Prop no mundo** — chegar perto de um dos props de `Config.UseProps` e interagir (target, se `Config.TargetSystem = true`; senão, marker + tecla).
3. **Posição livre** — chegar a uma das `Config.UsablePositions`. Ali qualquer jogador abre um computador sem precisar de item.

Cada computador ligado recebe um IP na rede interna do recurso. Laptops têm o IP removido ao fechar; computadores fixos apenas ficam marcados como offline — é isso que permite ao `netscan` e ao `ip-tracer` encontrarem máquinas de outros jogadores.

---

## Aplicativos

| App | Descrição |
|---|---|
| Console | Prompt de comando. É por onde passa a rede, os endereços e o data heist |
| Mail | Criação de conta, envio, resposta e leitura de e-mails. O endereço é `usuario` + `AppConfig.Mail.domain` |
| Market | Anúncios classificados. Limitado por `maxPosts` e `delayBetweenEachPost`; anúncios expiram após `timeBeforeAutomaticDeletion` |
| Addresses | Lista dos endereços de `AppConfig.Addresses` |
| Informations | Dados da máquina, incluindo o IP atual |
| Themes | Troca de tema entre os definidos em `AppConfig.Themes` |
| Browser | Container onde os endereços são renderizados |

---

## Console — comandos

Digitados dentro do app Console, não no chat do jogo. O console tem autocomplete com `Tab` e histórico com as setas.

| Comando | Descrição |
|---|---|
| `help` | Lista os comandos disponíveis |
| `version` | Versão do sistema |
| `clear` | Limpa a tela |
| `exit` | Fecha o console |
| `shutdown` | Desliga o computador |
| `start <app>` | Abre um aplicativo |
| `taskkill <app>` | Fecha um aplicativo |
| `netscan` | Lista os IPs ativos na rede |
| `ip-tracer -ip <ip>` | Localiza a máquina de um IP. Devolve `DISCONNECTED` se o IP não estiver online |
| `connect <endereço>` | Acessa um endereço de `AppConfig.Addresses` |
| `detect -ip` | **Data heist.** Detecta o servidor alvo se você estiver dentro de uma área configurada |
| `scan -ports <ip>` | **Data heist.** Descobre a porta aberta do alvo |
| `infiltrate -ip <ip> -port <porta>` | **Data heist.** Invade o servidor |
| `breach -ip <ip> -port <porta>` | **Data heist.** Extrai o dump e devolve o caminho de rede do arquivo |

---

## Data Heist

Roubo de dados feito inteiramente pelo console, dentro das áreas de `Config.DataHeists.Areas` (por padrão, as cinco agências Fleeca e o estacionamento da Arcadius Tower).

Fluxo: `detect -ip` para achar o alvo, `scan -ports` para descobrir a porta, `infiltrate` para entrar e `breach` para gerar o dump. O `breach` devolve um caminho de rede único (algo como `//breach-temp1234/breached/data/dump-5678`). Esse caminho é depois vendido no endereço `selldata.com`, que paga um valor sorteado entre `Config.DataHeists.Reward[1]` e `[2]`.

Cada assalto disparado envia o alerta `ccmp:dataHeistCall` com o GPS do jogador para todos os jogadores online cujo job esteja em `Config.DataHeists.JobsToCall`.

O servidor valida a distância do jogador até o centro da área em toda etapa, e o caminho de rede gerado só pode ser reclamado uma vez — e apenas na área em que foi criado. O cooldown é controlado por `Config.DataHeists.Delay`, por área ou global conforme `TypeOfDelay`.

---

## Endereços

Endereços são "sites" acessíveis pelo console com `connect <endereço>`. Vêm dois:

| Endereço | O que faz |
|---|---|
| `chat.incognito.net` | Chat anônimo entre todos os jogadores conectados ao endereço. Cada um escolhe um username ao entrar |
| `selldata.com` | Onde os dumps do data heist são vendidos |

Cada endereço é composto por três arquivos com o mesmo nome: `client/addresses/<endereço>.lua`, `server/addresses/<endereço>.lua` e `nui/addresses/<endereço>/` (com `app.js` e `app.css`). Adicionar um endereço novo significa criar esses arquivos e listar o nome em `AppConfig.Addresses`.

---

## Integrações

### ox_target / qb-target

Com `Config.TargetSystem = true`, os props de `Config.UseProps` recebem uma opção de target. O recurso é escolhido em `Config.TargetType` (`"ox"` ou `"qb"`). Com `TargetSystem = false`, nenhum dos dois é necessário: o recurso desenha o marker de `CustomDrawMarker` e checa a distância do jogador.

### Framework (QBCore / ESX)

O `server/main.lua` normaliza as funções dos dois frameworks (`RegisterServerCallback`, `GetPlayerFromId`, `RegisterUsableItem`, `GetPlayers`), então o resto do código é agnóstico. Se o carregamento falhar, o recurso imprime um erro no console pedindo para checar `Config.Framework` e `Config.FrameworkResourceName` — quase sempre é ordem de start no `server.cfg`.

---

## Entrypoints para outros recursos

Dois exports, do lado cliente:

```lua
-- Retorna true se o jogador está com um computador aberto.
local open = exports.cuchi_computer:isComputerOpen()

-- Retorna true se o computador aberto é um laptop (item), false se é um prop fixo.
local laptop = exports.cuchi_computer:isComputerALaptop()
```

### Evento de cliente

```lua
-- Abre a interface. É o mesmo evento disparado pelo item usável.
TriggerClientEvent('cuchi_computer:useItem', source)
```

---

## Localização

O idioma é definido por `Config.Locale` no `config.lua` (não usa convar):

```lua
Config.Locale = "PT" -- EN/FR/ES/DA/DE/PT
```

As traduções ficam duplicadas em dois lugares, porque a UI é NUI pura:

- `locales/lua/<idioma>.lua` — textos do lado do jogo (notificações, interações)
- `locales/ui/<idioma>.js` — textos da interface e do console

Idiomas disponíveis: `pt`, `en`, `fr`, `es`, `da`, `de`. Para adicionar um idioma, crie os dois arquivos e registre-os em `locales/main.lua` e `locales/main.js`.

---

## Estrutura de arquivos

```
cuchi_computer/
├── client/
│   ├── main.lua                       — props, zonas, markers, target, alerta de data heist
│   ├── nui.lua                        — abertura/fechamento da UI, callbacks NUI, exports
│   ├── overrides.lua                  — enfileira SendNUIMessage até a NUI estar pronta
│   └── addresses/
│       └── chat.incognito.net.lua     — lado cliente do chat anônimo
├── server/
│   ├── main.lua                       — bridge do framework, item usável, callbacks de IP e data heist
│   ├── applications.lua               — mercado e e-mail (queries do oxmysql)
│   ├── fakeIPs.lua                    — registro, consulta e remoção dos IPs da rede
│   ├── version.lua                    — checagem de versão
│   └── addresses/
│       └── chat.incognito.net.lua     — lado servidor do chat anônimo
├── shared/
│   └── functions.lua                  — helpers compartilhados
├── nui/
│   ├── index.html                     — shell do sistema operacional
│   ├── style.css                      — estilos (CSS puro, sem framework)
│   ├── scripts/
│   │   ├── script.js                  — janelas, apps, console
│   │   └── configs/
│   │       ├── applications.js        — definição dos apps (código HTML e tamanho de cada janela)
│   │       └── commands.js            — definição dos comandos do console
│   ├── addresses/
│   │   ├── chat.incognito.net/        — app.js e app.css do chat
│   │   └── selldata.com/              — app.js e app.css da venda de dumps
│   └── assets/                        — imagens dos apps e sons (boot, mensagem)
├── locales/
│   ├── main.lua / main.js             — carregadores de locale
│   ├── lua/                           — pt, en, fr, es, da, de (textos do jogo)
│   └── ui/                            — pt, en, fr, es, da, de (textos da interface)
├── assets/screen.gif                  — animação da tela (256x256, 1:1)
├── config.lua                         — framework, locale, item, props, target, data heist
├── app_config.lua                     — mercado, e-mail, endereços e temas
├── tables.sql                         — computers_market, computers_mail_accounts, computers_mail_mails
└── fxmanifest.lua
```
