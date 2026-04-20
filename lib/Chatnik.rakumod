use v6.d;

unit module Chatnik;

use LLM::Functions;
use LLM::Prompts;
use JSON::Fast;
use XDG::BaseDirectory :terms;

#==========================================================
# Chat objects location
#==========================================================
our sub get-chat-objects-file-name() {

    my $exportDir = data-home ~ '/raku/LLM/Chatnik';
    if !$exportDir.IO.d {
        try $exportDir.IO.mkdir;
        if $! {
            die "Cannot create the export directory $exportDir."
        }
    }

    return $exportDir ~ '/chat-objects.json';
}

#==========================================================
# Export
#==========================================================
our proto sub export-ready($chat) {*}

multi sub export-ready(LLM::Functions::Chat:D $chat) {
    my %res = $chat.Hash;
    %res<llm-evaluator><conf><evaluator> = Whatever;
    %res.deepmap({
        given $_ {
            when Whatever { 'Whatever' }
            when WhateverCode { 'WhateverCode' }
            when Routine { $_.name }
            when Callable { 'CALLABLE' }
            default { $_ }
        }
    })
}

multi sub export-ready(@chats where @chats.all ~~ LLM::Functions::Chat:D) {
    export-ready(@chats.map({ $_.chat-id => $_ }).Hash)
}

multi sub export-ready(%chats where %chats.values.all ~~ LLM::Functions::Chat:D) {
    %chats.map({ $_.key => export-ready($_.value) }).Hash
}

#| Export a hashmap of chat objects.
our sub export-chats(%chats where %chats.values.all ~~ LLM::Functions::Chat:D) {
    spurt(get-chat-objects-file-name(), to-json(export-ready(%chats)))
}

#==========================================================
# Import
#==========================================================
our sub to-chat-object(%spec, :$chat-id = Whatever) {
    my %confSpec = %spec<llm-evaluator><conf>;
    my %evalSpec = %spec<llm-evaluator>.grep(*.key ne 'conf');

    my $conf = llm-configuration(%confSpec<name>, model => %confSpec<model>, prompts => %confSpec<prompts>);

    my $chat = llm-chat(conf => %confSpec<name>, chat-id => $chat-id // %spec<chat-id>, prompt => %evalSpec<context>);

    # For each messages make the timestamp strings to be DateTime objects
    my $messages = %spec<messages>.map({ $_.map({ $_.key => $_.key eq 'timestamp' ?? DateTime.new($_.value) !! $_.value }).Hash });

    # It is very hard to convince Raku not to do containerization.
    $chat.messages = |$messages;

    $chat
}

our sub import-chats() {
    my %importedChats = from-json(slurp(Chatnik::get-chat-objects-file-name()));

    my %chats = %importedChats.map({
        my $chat = to-chat-object($_.value, chat-id => $_.key);
        $_.key => $chat
    });

    return %chats;
}

#==========================================================
# LLM configuration by any args
#==========================================================

our sub llm-configuration-by-args(*%args) {
    # Find known &llm-configuration parameters by class attributes
    my @knownParamNames = LLM::Functions::Configuration.^attributes.map(*.name)».subst(/ <[$@%&]> <[!.]>? /).sort;

    # Filter
    my %confArgs = %args.grep({ $_.key ∈ @knownParamNames });

    # Process provide::model shortcut spec
    if %confArgs<model> && %confArgs<model>.contains('::') {
        my ($provider, $model) = %confArgs<model>.split('::');
        # Provider names are different than the model families.
        $provider = do given $provider {
            when 'openai' { 'chatgpt' }
            when 'google' { 'gemini' }
            default { $_ }
        }
        %confArgs<model> = $model;
        %confArgs<name> = $provider
    }

    # Make the LLM configuration
    my %confArgs2 = %confArgs.grep(*.key ∉ <name conf>);
    return llm-configuration(%confArgs<name>, |%confArgs2);
}

#==========================================================
# Evaluate input message
#==========================================================

# This sub's code is almost the same as the code Magic::Chat.preprocess of "Jupyter::Chatbook".
our sub evaluate-message(Str:D $input, %chats, *%args) {

    # Process arguments
    %args .= map({ $_.key => $_.value.clone });
    
    # Get 
    my $chat-id = %args<chat-id> // %args<id> // %args<i> // 'NONE';

    # Expand the prompt if given
    my $prompt = %args<prompt> // '';
    if $prompt {
        $prompt = llm-prompt-expand($prompt);
        %args<prompt> = $prompt;
    }

    # Warn if an existing chat-id is used and are also given a prompt and configuration spec
    if ( (%args<prompt> // False) || (%args<conf> // False) ) && (%chats{$chat-id}:exists) {
        note "No new chat object is created.\nUsing chat object with id: ⎡{$chat-id}⎦, and number of messages: {%chats{$chat-id}.messages.elems}.";
    }

    # Create an LLM configuration
    my $conf = llm-configuration-by-args(|%args);

    # Make the chat-object args
    my %chat-args = { :$conf, :$chat-id } , %args.grep({ $_.key ∉ <conf name model> }).Hash;

    # Get chat object
    my $chatObj = %chats{$chat-id} // llm-chat(|%chat-args);

    # We get a  delimiter from the configuration
    # my $sep = $chatObj.llm-evaluator.conf.prompt-delimiter;
    # But for prompt expansions it is most like better to use new line
    my $sep = "\n";

    # Call LLM's interface function
    my $res;
    try {
        $res = $chatObj.eval(llm-prompt-expand($input, messages => $chatObj.messages.map({ $_<content> }).Array, :$sep));
    }
    if $! {
        note "Cannot process the input with chat object's LLM evaluator.";
        $res = $!.payload;
    }

    # Make sure it is registered
    %chats{$chat-id} = $chatObj;

    return $res;
}

#==========================================================
# Load predefined LLM-personas
#==========================================================

#| Load LLM personas defined in JSON file.
our proto sub load-llm-personas(|--> Map:D) {*}

# This sub is almost the same as method get-user-llm-personas(--> Map:D) of unit class Jupyter::Chatbook::Magics
# of "Jupyter::Chatbook".
multi sub load-llm-personas(--> Map:D) {
    my $base = %*ENV<XDG_HOME> // $*HOME.child('.config');
    $base = $base.child('raku-chatbook') // $*HOME.child('.config');
    my $conf-file = %*ENV<RAKU_CHATBOOK_LLM_PERSONAS_CONF> // $base.child('llm-personas.json');
    return load-llm-personas($conf-file);
}

multi sub load-llm-personas($conf-file where $conf-file ~~ (Str:D | IO::Path:D)--> Map:D) {
    if $conf-file.IO.e {
        #debug "Reading configuration from $conf-file";
        try {
            my @specs = |from-json($conf-file.IO.slurp);
            if @specs ~~ (List:D | Array:D | Seq:D) && @specs.all ~~ Map:D {
                # Merge magic arguments with defaults
                my %personas = do for @specs.kv -> $i, %p {
                    # Merge with defaults
                    my %h = %(conf => 'ChatGPT', chat-id => "p$i" ), %p;
                    # Expand prompt
                    if %h<prompt>:exists {
                        %h<prompt> = llm-prompt-expand(%h<prompt>)
                    }
                    # Make a chat object
                    %h<chat-id> => llm-chat(|%h);
                }
                return %personas;
            }
        }
    }
    note "Cannot find the file $conf-file.";
    return %();
}