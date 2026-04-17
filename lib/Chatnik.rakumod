use v6.d;

unit module Chatnik;

use LLM::Functions;
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
    $chat.Hash.deepmap({
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

our sub import-chats() {
    my %importedChats = from-json(slurp(Chatnik::get-chat-objects-file-name()));

    my %chatsSession = %importedChats.map({
        my %confSpec = $_.value<llm-evaluator><conf>;
        my $conf = llm-configuration(%confSpec<name>, model => %confSpec<model>, prompts => %confSpec<prompts> );
        my $llm-evaluator = LLM::Functions::EvaluatorChatGemini.new(:$conf);
        $_.key => LLM::Functions::Chat.new(:$llm-evaluator, chat-id => $_.key, messages => |$_.value<messages>);
    })
}