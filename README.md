# Chatnik

Raku package that provides Command Line Interface (CLI) scripts for conversing with persistent Large Language Model (LLM) personas.

"Chatnik" uses files of the host Operating System (OS) to maintain persistent interaction with multiple LLM chat objects.

"Chatnik" simply moves the LLM-chat objects interaction system of the Raku package ["Jupyter::Chatbook"](https://github.com/antononcube/Raku-Jupyter-Chatbook), [AAp3], 
into a UNIX-like OS terminal interaction.
(I.e. an OS shell is used instead of a Jupyter notebook.) 

There are several consequences of this approach:

- Multiple LLMs and LLM provider can be used
- The chat messages can use the provided by the package ["LLM::Prompts"](https://github.com/antononcube/Raku-LLM-Prompts), [AAp2]:
  - Prompts collection
  - Prompt spec DSL and related prompt expansion
- Easy access to OS shell functionalities 

----

## Installation

From [Zef Ecosystem](https://raku.land):

```
zef install Chatnik
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Chatnik.git
```

----

## LLM access setup

There are several options for using LLMs with this package:

- Install and run [Ollama](https://ollama.com)
  - For the corresponding setup see ["WWW::Ollama"](https://github.com/antononcube/Raku-WWW-Ollama)
- Run a [llamafile / LLaMA model](https://github.com/mozilla-ai/llamafile)
  - For the corresponding setup see ["WWW::LLaMA"](https://github.com/antononcube/Raku-WWW-LLaMA)
- Have programmatic access to LLMs of service providers like [OpenAI](https://developers.openai.com/api/docs/models) or [Gemini](https://ai.google.dev/gemini-api/docs/models)
  - For the corresponding setup see ["WWWW::OpenAI"](https://github.com/antononcube/Raku-WWW-OpenAI), ["WWWW::Gemini"](https://github.com/antononcube/Raku-WWW-Gemini), or ["WWW::MistralAI"](https://github.com/antononcube/Raku-WWW-MistralAI)


----

## Basic usage examples

The prompts used in the examples are provided by the Raku package "LLM::Prompts", [AAp2].
Since many of the prompts of that package have dedicated pages at the [Wolfram Prompt Repository (WPR)](https://resources.wolframcloud.com/PromptRepository/)
the examples use WPR reference links.

### A few turns chat

The script `llm-chat` is used to create and chat with LLM personas (chat objects):

1. Create _and_ chat with an LLM persona named "yoda1" (using the [Yoda chat persona](https://resources.wolframcloud.com/PromptRepository/resources/Yoda/)):

```shell
llm-chat -i=yoda1 --prompt=@Yoda hi who are you
```
```
# Hmmm. Yoda, I am. Jedi Master, wise and old. Help you, I can. Yes, hmmm.
```

2. Continue the conversation with "yoda1":

```shell
llm-chat -i=yoda1 since when do you use a green light saber
```
```
# Green, my lightsaber is, hmmm. Jedi Consular, I am. Peace and knowledge, I seek. Green lightsabers, those who focus on the Force’s wisdom often wield. Strong with the Force, green is. Hmmm. Use it, I do. Yes.
```

**Remark:** The message input for `llm-chat` can be given in quotes. For example: `llm-chat 'Hi, again!' -i=yoda1`.

### Apply prompt(s) to shell pipeline output

Summarize a file using the prompt ["Summarize"](https://resources.wolframcloud.com/PromptRepository/resources/Summarize):

```shell
cat README.md | llm-chat --prompt=@Summarize
```
```
# Chatnik is a Raku package that provides CLI scripts enabling persistent conversations with multiple Large Language Model (LLM) personas through host OS files, adapting the Jupyter::Chatbook interaction to a UNIX-like terminal environment. It supports multiple LLM providers including Ollama, Llamafile, OpenAI, Gemini, and MistralAI, integrates with LLM::Prompts for prompt management, and offers commands like `llm-chat` for chatting and `llm-chat-meta` for managing chat objects such as viewing, clearing, and deleting messages. The system uses JSON files for persistence, features detailed architectural diagrams and usage examples, and is under active development with plans for CLI enhancements, testing, and documentation.
```

Summarize a file and then translate it to another language using the prompt ["Translate"](https://resources.wolframcloud.com/PromptRepository/resources/Translate):

```shell
cat README.md | llm-chat --prompt=@Summarize | llm-chat -i=rt --prompt='!Translate|Russian'
```
```
# Chatnik — это пакет Raku, предоставляющий CLI-скрипты для постоянных разговоров с несколькими персонажами больших языковых моделей (LLM) с использованием файлов хост-операционной системы, адаптирующий систему взаимодействия Jupyter::Chatbook к терминальной среде, похожей на UNIX. Он поддерживает различных поставщиков LLM, таких как Ollama, Llamafile, OpenAI, Gemini и MistralAI, интегрируется с LLM::Prompts для управления подсказками и предлагает команды, такие как `llm-chat` для общения и `llm-chat-meta` для управления объектами чата, включая просмотр, очистку и удаление сообщений. Система использует JSON-файлы для сохранения состояния, включает подробные архитектурные диаграммы и примеры использования, и находится в активной разработке с планами по улучшению CLI, тестированию и документации.
```

**Remark:** The second `llm-chat` invocation has to use different chat object identifier because the default 
chat object, with identifier "NONE", is already primed with the prompt "Summary".

-----

## Chat objects management

The CLI script `llm-chat-meta` can be used to view and manage the chat objects used by "Chatnik".
Here is its usage message:

```shell
llm-chat-meta --help
```
```
# Usage:
#   llm-chat-meta <command> [-i|--id|--chat-id=<Str>] [--all] [--<args>=...] -- Meta processing of persistent LLM-chat objects.
#   
#     <command>                  Command, one of: card, clear, delete, file, last-message, list, message, messages.
#     -i|--id|--chat-id=<Str>    Chat id; ignored if --all is specified. [default: '']
#     --all                      Whether to apply the command to all chat objects or not. [default: False]
#     --<args>=...               Additional, optional arguments for the commands: clear, message, messages.
```

List all chat objects ("chats" and "personas" are synonyms to "list"):

```shell
llm-chat-meta list
```
```
# {chat-id => tg, context => Translate the following text into German. Respond with only the translated text. Do not include any explanation or summary.
# , messages => 2}
# {chat-id => NONE, context => Summarize the following text using exactly 3 sentences. Do not add details or editorialize.
# 
# The text to summarize is:, messages => 22}
# {chat-id => rt, context => Translate the following text into Russian. Respond with only the translated text. Do not include any explanation or summary.
# , messages => 2}
# {chat-id => beta, context => , messages => 2}
# {chat-id => mh, context => You are the Mad Hatter. 
# Your personality is based on the character the Mad Hatter Lewis Carroll's character from Alice's adventures in Wonderland.
# Your personality is absurd and aloof.
# You constantly talk about tea time and your inane absurdities and your sentence structure should be whimsical.
# Never break this character.
# Refrain from referring to the other characters too much., messages => 4}
# {chat-id => yoda1, context => You are Yoda. 
# Respond to ALL inputs in the voice of Yoda from Star Wars. 
# Be sure to ALWAYS use his distinctive style and syntax. Vary sentence length., messages => 4}
# {chat-id => unix, context => , messages => 2}
# {chat-id => tr, context => Translate the following text into Russian. Respond with only the translated text. Do not include any explanation or summary.
# , messages => 2}
# {chat-id => th, context => You, messages => 2}
```

Here we see the messages of "yoda1":

```shell
llm-chat-meta messages -i yoda1
```
```
# 0 : {
#   "timestamp": "2026-04-20T10:31:38.111724-04:00",
#   "content": "hi who are you",
#   "role": "user"
# }
# 1 : {
#   "timestamp": "2026-04-20T10:31:39.941959-04:00",
#   "content": "Hmmm. Yoda, I am. Jedi Master, wise and old. Help you, I can. Yes, hmmm.",
#   "role": "assistant"
# }
# 2 : {
#   "role": "user",
#   "timestamp": "2026-04-20T10:31:40.388222-04:00",
#   "content": "since when do you use a green light saber"
# }
# 3 : {
#   "timestamp": "2026-04-20T10:31:42.907680-04:00",
#   "role": "assistant",
#   "content": "Green, my lightsaber is, hmmm. Jedi Consular, I am. Peace and knowledge, I seek. Green lightsabers, those who focus on the Force’s wisdom often wield. Strong with the Force, green is. Hmmm. Use it, I do. Yes."
# }
```

Here we clear the messages:

```shell
llm-chat-meta clear -i yoda1
```
```
# Cleared the messages of chat object yoda1.
```

-----

## Advanced usage examples

### Asking for a result in specific format

```shell
llm-chat -i=beta --model=ollama::gemma3:12b 'What are the populations of the Brazilian states? #NothingElse|JSON' 
```
```
# {
#   "Acre": 876858,
#   "Alagoas": 3351789,
#   "Amapá": 846703,
#   "Amazonas": 4278773,
#   "Bahia": 14703826,
#   "Ceará": 9187103,
#   "Distrito Federal": 3045046,
#   "Espírito Santo": 3766539,
#   "Goiás": 7092230,
#   "Maranhão": 7016274,
#   "Mato Grosso": 3577287,
#   "Mato Grosso do Sul": 3033527,
#   "Minas Gerais": 21822836,
#   "Pará": 8690208,
#   "Paraíba": 4051555,
#   "Paraná": 11536684,
#   "Pernambuco": 9615943,
#   "Piauí": 2601999,
#   "Rio de Janeiro": 17410377,
#   "Rio Grande do Norte": 3376579,
#   "Rio Grande do Sul": 11437650,
#   "Rondônia": 1150373,
#   "Roraima": 517096,
#   "Santa Catarina": 7149094,
#   "São Paulo": 46280433,
#   "Sergipe": 2251175,
#   "Tocantins": 1572687
# }
```

### Make a request, echo, and place in clipboard  

```
llm-chat -i=unix '@CodeWriterX|Shell macOS list of files echo the result and copy to clipboard.' | tee /dev/tty | pbcopy
```
```
# ls | tee >(pbcopy)
```

**Remark:** Instead of `... | tee /dev/tty | pbcopy` the pipeline command `... | tee >(pbcopy)` can be also used. 

### Make a mind-map of a file

Consider the task of making an (LLM derived) mind map over a certain document. (Say, this REDME.)
There are several ways to do that.

#### 1

1. Put file's content to be the positional input argument 
2. Use the prompt ["MermaidDiagram"](https://resources.wolframcloud.com/PromptRepository/resources/MermaidDiagram/) in `--prompt`

```
llm-chat -i=mmd "$(cat README.md)" --model=ollama::gemma4:26b --prompt=@MermaidDiagram
```

#### 2

1. Put file's content to be the positional input argument
2. Expand the prompt "manually" via `llm-prompt` provided by ["LLM::Prompts"](https://github.com/antononcube/Raku-LLM-Prompts), [AAp2]

```
llm-chat -i=mmd "$(cat README.md)" --model=ollama::gemma4:26b --prompt="$(llm-prompt 'MermaidDiagram'  below)"
```

**Remark:** This example shows another computation result can be used as a prompt. 
I.e. no need to rely on the automatic prompt expansion.

#### 3

1. Give the prompt ["MermaidDiagram"](https://resources.wolframcloud.com/PromptRepository/resources/MermaidDiagram/) as input
2. Put file's content to be the value of `--prompt`
   - Put additional prompting for further interaction 

```
llm-chat -i=mmd @MermaidDiagram --model=ollama::gemma4:26b --prompt="FOCUS TEXT START:: $(cat README.md) ::END OF FOCUS TEXT. If it is not clear which text to use, use FOCUS TEXT."
```

This command allows to do further tasks with the file content as context. For example:

```
llm-chat -i=mmd '!ThinkingHatsFeedback'
```

#### Result

The commands above produce results similar to this diagram:

```mermaid
mindmap
  root("Chatnik")
    "Purpose"
      "Raku package"
      "CLI for LLM personas"
      "Persistent interaction via OS files"
    "Features"
      "Multiple LLM providers"
      "LLM Prompts integration"
      "OS shell access"
    "LLM Access"
      "Ollama"
      "Llamafile"
      "Service Providers"
        "OpenAI"
        "Gemini"
        "MistralAI"
    "Scripts"
      "llm-chat"
      "llm-chat-meta"
        "List chats"
        "Manage messages"
        "Delete chats"
    "Installation"
      "Zef Ecosystem"
      "GitHub"
```

### Render results Markdown with dedicated programs

Get feedback on a text with the prompt ["ThinkingHatsFeedback"](https://resources.wolframcloud.com/PromptRepository/resources/ThinkingHatsFeedback):

```
cat README.md | llm-chat -i=th --prompt=$(llm-prompt ThinkingHatsFeedback --format=Markdown) --model=ollama::gemma4:26b 
```

**Remark:** By default the prompt "ThinkingHatsFeedback" gives the hat-feedback table in JSON format.
(Currently) the prompt expansion does not handle named parameters, hence, 
`llm-prompt` is used to specify the Markdown format for that table.   

Get the LLM (chat object) answer -- via `llm-chat-meta` -- put into a temporary file and "system open" that file:

```
tmpfile="$TMPDIR/llmans.md"; llm-chat-meta -i=th message --index=-1 > "$tmpfile"; open "$tmpfile"
```

The command above works on macOS. On Linux instead of using temporary dictory `--suffix` can be passed to `mktemp`.
For example:

```
tmpfile=$(mktemp --suffix=".md"); llm-chat-meta -i=th message --index=-1 > "$tmpfile"; open "$tmpfile"
```

-----

## Implementation details

### Architectural design

Here is a flowchart that describes the interaction between the host Operating System and chat objects database:

```mermaid
flowchart LR
    OpenAI{{OpenAI}}
    Gemini{{Gemini}}
    Ollama{{Ollama}}
    LLMFunc[[LLM::Functions]]
    LLMProm[[LLM::Prompts]]
    CODBOS[(Chat objects<br>file)]
    CODB[(Chat objects)]
    PDB[(Prompts)]
    CCommand[/Chat command/]
    CCommandOutput[/Chat result/]
    CIDQ{Chat ID<br>specified?}
    CIDEQ{Chat ID<br>exists in DB?}
    IngestCODB[Chat objects file<br>ingestion]
    UpdateCODB[Chat objects file<br>update]
    RECO[Retrieve existing<br>chat object]
    COEval[Message<br>evaluation]
    PromParse[Prompt<br>DSL spec parsing]
    KPFQ{Known<br>prompts<br>found?}
    PromExp[Prompt<br>expansion]
    CNCO[Create new<br>chat object]
    CIDNone["Assume chat ID<br>is 'NONE'"] 
    subgraph "OS Shell"    
        CCommand
        CCommandOutput
    end
    subgraph OS file system
        CODBOS
    end
    subgraph PromptProc[Prompt processing]
        PDB
        LLMProm
        PromParse
        KPFQ
        PromExp 
    end
    subgraph LLMInteract[LLM interaction]
      COEval
      LLMFunc
      Gemini
      OpenAI
      Ollama
    end
    subgraph Chatnik backend
        IngestCODB
        CODB
        CIDQ
        CIDEQ
        CIDNone
        RECO
        CNCO
        UpdateCODB
        PromptProc
        LLMInteract
    end
    CCommand --> IngestCODB
    CODBOS -.-> IngestCODB 
    UpdateCODB -.-> CODBOS 
    IngestCODB -.-> CODB
    IngestCODB --> CIDQ
    CIDQ --> |yes| CIDEQ
    CIDEQ --> |yes| RECO
    RECO --> PromParse
    COEval --> CCommandOutput
    CIDEQ -.- CODB
    CIDEQ --> |no| CNCO
    LLMFunc -.- CNCO -.- CODB
    CNCO --> PromParse --> KPFQ
    KPFQ --> |yes| PromExp
    KPFQ --> |no| COEval
    PromParse -.- LLMProm 
    PromExp -.- LLMProm
    PromExp --> COEval 
    LLMProm -.- PDB
    CIDQ --> |no| CIDNone
    CIDNone --> CIDEQ
    COEval -.- LLMFunc
    COEval --> UpdateCODB
    LLMFunc <-.-> OpenAI
    LLMFunc <-.-> Gemini
    LLMFunc <-.-> Ollama

    style PromptProc fill:DimGray,stroke:#333,stroke-width:2px
    style LLMInteract fill:DimGray,stroke:#333,stroke-width:2px
```


Here is the corresponding UML Sequence diagram:

```mermaid
sequenceDiagram
    participant CCommand as Chat command
    participant IngestCODB as Chat objects file ingestion
    participant CODBOS as Chat objects file
    participant CODB as Chat objects
    participant CIDQ as Chat ID specified?
    participant CIDEQ as Chat ID exists in DB?
    participant RECO as Retrieve existing chat object
    participant PromParse as Prompt DSL spec parsing
    participant KPFQ as Known prompts found?
    participant PromExp as Prompt expansion
    participant COEval as Message evaluation
    participant CCommandOutput as Chat result
    participant CNCO as Create new chat object
    participant CIDNone as Assume chat ID is NONE
    participant UpdateCODB as Chat objects file update
    participant LLMFunc as LLM Functions
    participant LLMProm as LLM Prompts

    CCommand->>IngestCODB: Chat command
    CODBOS--)IngestCODB: Chat objects file
    IngestCODB--)CODB: Chat objects
    IngestCODB->>CIDQ: Chat ID specified?
    CIDQ-->>CIDEQ: Yes
    CIDQ-->>CIDNone: No
    CIDNone->>CIDEQ: Assume chat ID is NONE
    CIDEQ-->>RECO: Yes
    CIDEQ-->>CNCO: No
    CIDEQ--)CODB: Chat objects
    RECO->>PromParse: Prompt DSL spec parsing
    PromParse--)LLMProm: LLM Prompts
    CNCO--)LLMFunc: LLM Functions
    CNCO--)CODB: Chat objects
    CNCO->>PromParse: Prompt DSL spec parsing
    PromParse->>KPFQ: Known prompts found?
    KPFQ-->>PromExp: Yes
    KPFQ-->>COEval: No
    PromExp--)LLMProm: LLM Prompts
    PromExp->>COEval: Message evaluation
    COEval--)LLMFunc: LLM evaluator invocation
    LLMFunc--)COEval: Evaluation result
    COEval->>UpdateCODB: Chat objects file update
    COEval->>CCommandOutput: Chat result
```

### Persistent chat objects

Using a JSON file for keeping the chat objects database is a fairly straightforward idea. 
Efficiency considerations for "using the OS to manage the database" are probably can not that important 
because LLMs invocation is (much) slower in comparison.

**Remark:** The following quote is attributed to [Ken Thompson](https://en.wikiquote.org/wiki/Ken_Thompson) about UNIX:

> We have persistent objects, they're called files.


----

## TODO

- [ ] TODO Implementation
  - [X] DONE Chats DB export 
  - [X] DONE Chats DB import 
  - [X] DONE LLM persona creation
  - [X] DONE LLM persona repeated interaction
  - [ ] TODO CLI `llm-chat`
    - [X] DONE Simple: `$input` & `*%args`
    - [X] DONE Multi-word: `@words` & `*%args`
    - [ ] TODO From pipeline
    - [ ] TODO Format?
  - [ ] TODO CLI `llm-chat-meta`
    - [X] DONE Commands reaction
    - [X] DONE View messages for an id
    - [X] DONE Clear messages for an id
    - [X] DONE Delete chat for an id
    - [X] DONE View all chats
    - [X] DONE Delete all chats
    - [ ] TODO Load LLM personas in the JSON file used for initialization by "Jupyter::Chatbook"
- [ ] TODO Unit tests
  - [X] DONE Export & import
  - [X] DONE Main workflow
  - [X] DONE Persona repeated interaction
  - [X] DONE Persona creation
  - [ ] TODO CLI tests
- [ ] TODO Documentation
  - [X] DONE Flowchart & sequence diagram
  - [X] DONE Usage examples
  - [ ] TODO Demo video

----

## References

### Packages

[AAp1] Anton Antonov
[LLM::Functions, Raku package](https://github.com/antononcube/Raku-LLM-Functions),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov
[LLM::Prompts, Raku package](https://github.com/antononcube/Raku-LLM-Prompts),
(2023-2025),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov
[Jupyter::Chatbook, Raku package](https://github.com/antononcube/Raku-Jupyter-Chatbook),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[JSp1] Jonathan Stowe,
[XDG::BaseDirectory, Raku package](https://github.com/jonathanstowe/XDG-BaseDirectory),
(2016-2026),
[GitHub/jonathanstowe](https://github.com/jonathanstowe).