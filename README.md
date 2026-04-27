# Chatnik

Raku package that provides Command Line Interface (CLI) scripts for conversing with persistent Large Language Model (LLM) personas.

"Chatnik" uses files of the host Operating System (OS) to maintain persistent interaction with multiple LLM chat objects.

"Chatnik" can be seen as a package that "moves" the LLM-chat objects interaction system of the Raku package ["Jupyter::Chatbook"](https://github.com/antononcube/Raku-Jupyter-Chatbook), [AAp3],
into typical OS shell interaction.
(I.e. an OS shell is used instead of a Jupyter notebook.)

There are several consequences of this approach:

- Multiple LLMs and LLM providers can be used
- The chat messages can use the provided by the package ["LLM::Prompts"](https://github.com/antononcube/Raku-LLM-Prompts), [AAp2]:
  - Prompts collection
  - Prompt spec DSL and related prompt expansion
- Easy access to OS shell functionalities

**Remark:** The package ["LLM::DWIM"](https://raku.land/zef:bduggan/LLM::DWIM), [BDp1], is very similar in spirit to "Chatnik".
"LLM::DWIM" does not use prompt expansion, uses only one chat object, and, although it saves chat history, it does not create chat objects with that history.
Both packages are based on the LLM packages "LLM::Functions", [AAp1], and "LLM::Prompts", [AAp2].

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
# Hmm, a question you ask, yes. Yoda, I am. Jedi Master of wisdom and the Force, I have been for many years. Help you, I can. Hmm.
```

2. Continue the conversation with "yoda1":

```shell
llm-chat -i=yoda1 since when do you use a green light saber
```
```
# Green, my lightsaber is. Symbol of the Jedi Consular, it is. Wisdom and harmony with the Force, it represents. Many years ago, I chose this color, yes. Strong with the Force, I am. Hmmm.
```

**Remark:** The message input for `llm-chat` can be given in quotes. For example: `llm-chat 'Hi, again!' -i=yoda1`.

**Remark:** The script `chatnik` can be used instead of `llm-chat`.

### Apply prompt(s) to shell pipeline output

Summarize a file using the prompt ["Summarize"](https://resources.wolframcloud.com/PromptRepository/resources/Summarize):

```shell
cat README.md | llm-chat --prompt=@Summarize
```
```
# Chatnik is a Raku package that provides CLI scripts for persistent conversations with multiple Large Language Model (LLM) personas, using host OS files to manage chat objects and adapting the Jupyter::Chatbook system for UNIX-like terminal use. It supports various LLM providers including Ollama, Llamafile, OpenAI, Gemini, and MistralAI, integrates with the LLM::Prompts package for prompt management, and offers commands such as `llm-chat` and `llm-chat-meta` for chatting and managing chat objects stored in JSON files. The package includes detailed usage examples, architectural diagrams, and is actively developed, with ongoing work on testing, documentation, and additional CLI features.
```

Summarize a file and then translate it to another language using the prompt ["Translate"](https://resources.wolframcloud.com/PromptRepository/resources/Translate):

```shell
cat README.md | llm-chat --prompt=@Summarize | llm-chat -i=rt --prompt='!Translate|Russian'
```
```
# Chatnik — это пакет для Raku, предоставляющий CLI-скрипты для постоянных разговоров с несколькими персонажами Больших Языковых Моделей (LLM), используя файлы хост-операционной системы для управления объектами чата, адаптирующий модель взаимодействия пакета Jupyter::Chatbook для использования в терминалах UNIX-подобных систем. Он поддерживает различных провайдеров LLM, включая Ollama, Llamafile, OpenAI, Gemini и MistralAI, интегрируется с пакетом LLM::Prompts для управления подсказками и предлагает команды, такие как `llm-chat` и `llm-chat-meta`, для общения и управления объектами чата, хранящимися в JSON-файлах. Пакет содержит подробные примеры использования, архитектурные схемы и активно развивается с текущей работой над тестированием, документацией и дополнительными функциями CLI.
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
# {chat-id => yoda1, context => You are Yoda. 
# Respond to ALL inputs in the voice of Yoda from Star Wars. 
# Be sure to ALWAYS use his distinctive style and syntax. Vary sentence length., messages => 4}
# {chat-id => NONE, context => Summarize the following text using exactly 3 sentences. Do not add details or editorialize.
# 
# The text to summarize is:, messages => 4}
# {chat-id => rt, context => Translate the following text into Russian. Respond with only the translated text. Do not include any explanation or summary.
# , messages => 2}
```

Here we see the messages of "yoda1":

```shell
llm-chat-meta messages -i yoda1
```
```
# 0 : {
#   "timestamp": "2026-04-20T14:41:36.477725-04:00",
#   "role": "user",
#   "content": "hi who are you"
# }
# 1 : {
#   "content": "Hmm, a question you ask, yes. Yoda, I am. Jedi Master of wisdom and the Force, I have been for many years. Help you, I can. Hmm.",
#   "role": "assistant",
#   "timestamp": "2026-04-20T14:41:38.974576-04:00"
# }
# 2 : {
#   "timestamp": "2026-04-20T14:41:39.376836-04:00",
#   "content": "since when do you use a green light saber",
#   "role": "user"
# }
# 3 : {
#   "content": "Green, my lightsaber is. Symbol of the Jedi Consular, it is. Wisdom and harmony with the Force, it represents. Many years ago, I chose this color, yes. Strong with the Force, I am. Hmmm.",
#   "role": "assistant",
#   "timestamp": "2026-04-20T14:41:41.125165-04:00"
# }
```

Here we clear the messages:

```shell
llm-chat-meta clear -i yoda1
```
```
# Cleared the messages of chat object yoda1.
```

**Remark:** Calling the script `chatnik` with the command `meta` has the same effect as `llm-chat-meta`.
For example, `chatnik meta clear -i yoda1` can be used instead of the previous command.

-----

## Advanced usage examples

### Asking for a result in specific format

```shell
llm-chat -i=beta --model=ollama::gemma3:12b 'What are the populations of the Brazilian states? #NothingElse|JSON' 
```
```
# ```json
# {
#   "states": {
#     "Acre": 876722,
#     "Alagoas": 3432782,
#     "Amapá": 864069,
#     "Amazonas": 4269579,
#     "Bahia": 14703873,
#     "Ceará": 9187103,
#     "Distrito Federal": 3045155,
#     "Espírito Santo": 3735209,
#     "Goiás": 7083506,
#     "Maranhão": 7014639,
#     "Mato Grosso": 3521734,
#     "Mato Grosso do Sul": 2772700,
#     "Minas Gerais": 21529000,
#     "Pará": 8690903,
#     "Paraíba": 4051726,
#     "Paraná": 11473399,
#     "Pernambuco": 9615955,
#     "Piauí": 6575905,
#     "Rio de Janeiro": 17471677,
#     "Rio Grande do Norte": 3484232,
#     "Rio Grande do Sul": 11390092,
#     "Rondônia": 1137329,
#     "Roraima": 517097,
#     "Santa Catarina": 7149943,
#     "São Paulo": 46280442,
#     "Sergipe": 2251137,
#     "Tocantins": 1572237
#   }
# }
# ```
```

### Make a request, echo, and place in clipboard  

```
llm-chat -i=unix '@CodeWriterX|Shell macOS list of files echo the result and copy to clipboard.' | tee /dev/tty | pbcopy
```
```
#  ls | tee >(pbcopy) 
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
    Purpose
      Raku package
      CLI for LLM personas
      Persistent interaction via OS files
    Features
      Multiple LLM providers
      LLM Prompts integration
      OS shell access
    LLM Access
      Ollama
      Llamafile
      Service Providers
        OpenAI
        Gemini
        MistralAI
    Scripts
      llm-chat
      llm-chat-meta
        List chats
        Manage messages
        Delete chats
    Installation
      Zef Ecosystem
      GitHub
```

### Render results Markdown with dedicated programs

Get feedback on a text with the prompt ["ThinkingHatsFeedback"](https://resources.wolframcloud.com/PromptRepository/resources/ThinkingHatsFeedback):

```
cat README.md | llm-chat -i=th --prompt="$(llm-prompt ThinkingHatsFeedback 'the TEXT is GIVEN BELOW.' --format=Markdown)" --model=ollama::gemma4:26b 
```

**Remark:** By default the prompt "ThinkingHatsFeedback" gives the hat-feedback table in JSON format.
(Currently) the prompt expansion does not handle named parameters, hence, 
`llm-prompt` is used to specify the Markdown format for that table.   

Get the LLM (chat object) answer -- via `llm-chat-meta` -- put into a temporary file and "system open" that file:

```
tmpfile="$TMPDIR/llmans.md"; llm-chat-meta -i=th last-message > "$tmpfile"; open "$tmpfile"
```

The command above works on macOS. On Linux instead of explicitly creating a file in the temporary dictory,
the argument `--suffix` can be passed to `mktemp`. For example:

```
tmpfile=$(mktemp --suffix=".md"); llm-chat-meta -i=th last-message > "$tmpfile"; open "$tmpfile"
```

-----

## Customization

### Default model

Default model can be specified with the env variable `CHATNIK_DEFAULT_MODEL`. For example:

```
export CHATNIK_DEFAULT_MODEL=ollama::gemma4:26b
```

Remove with `unset CHATNIK_DEFAULT_MODEL`.

### Pre-defined LLM personas

Use defined LLM personas are specified with JSON file with a content like this:

```json
[
    {
	"chat-id": "raku",
	"conf": "ChatGPT",
	"prompt": "@CodeWriterX|Raku",
	"model": "gpt-4o",
	"max-tokens": 4096,
	"temperature": 0.4
    }
]
```

(See such a file [here](https://github.com/antononcube/Raku-Jupyter-Chatbook/blob/master/resources/llm-personas.json).)

The LLM personas JSON file can be specified with the OS environmental variables
`CHATNIK_LLM_PERSONAS_CONF` or `RAKU_CHATBOOK_LLM_PERSONAS_CONF` -- the former has precedence over the latter.

To load the predefined LLM personas use the command:

```
llm-chat-meta load-llm-personas
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
  - [X] DONE CLI `llm-chat`
    - [X] DONE Simple: `$input` & `*%args`
    - [X] DONE Multi-word: `@words` & `*%args`
    - [X] DONE From pipeline
    - [X] CANCELED Format? 
  - [X] DONE CLI `llm-chat-meta`
    - [X] DONE Commands reaction
    - [X] DONE View messages for an id
    - [X] DONE Clear messages for an id
    - [X] DONE Delete chat for an id
    - [X] DONE View all chats
    - [X] DONE Delete all chats
    - [X] DONE Clear message for an id by range
    - [X] DONE Take message for an id by index
    - [X] DONE Take last message for an id
    - [X] DONE Load LLM personas in the JSON file used for initialization by "Jupyter::Chatbook"
- [ ] TODO Unit tests
  - [X] DONE Export & import
  - [X] DONE Main workflow
  - [X] DONE Persona repeated interaction
  - [X] DONE Persona creation
  - [ ] TODO CLI tests
- [ ] TODO Documentation
  - [X] DONE Flowchart & sequence diagram
  - [X] DONE Usage examples
    - [X] DONE Basic examples
    - [X] DONE Advanced examples
    - [X] DONE Management (meta) examples
  - [ ] TODO Demo video

----

## References

### Packages

[AAp1] Anton Antonov,
[LLM::Functions, Raku package](https://github.com/antononcube/Raku-LLM-Functions),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[LLM::Prompts, Raku package](https://github.com/antononcube/Raku-LLM-Prompts),
(2023-2025),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[Jupyter::Chatbook, Raku package](https://github.com/antononcube/Raku-Jupyter-Chatbook),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[BDp1] Brian Duggan,
[LLM::DWIM, Raku package](https://github.com/bduggan/raku-llm-dwim),
(2024-2025),
[GitHub/bduggan](https://github.com/bduggan).

[JSp1] Jonathan Stowe,
[XDG::BaseDirectory, Raku package](https://github.com/jonathanstowe/XDG-BaseDirectory),
(2016-2026),
[GitHub/jonathanstowe](https://github.com/jonathanstowe).