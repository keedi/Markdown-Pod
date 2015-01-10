# NAME

Markdown::Pod - Convert Markdown to POD

# VERSION

version 0.005

# SYNOPSIS

    use Markdown::Pod;
    
    my $m2p = Markdown::Pod->new;
    my $pod = $m2p->markdown_to_pod(
        markdown => $markdown,
    );

# DESCRIPTION

This module parses Markdown text and return POD text.
It uses [Markdent](https://metacpan.org/pod/Markdent) module to parse Markdown.
Due to POD doesn't support blockquoted HTML tag,
so quoted text of Markdown will not be handled properly.
Quoted text will be converted to POD verbatim section.

# ATTRIBUTES

## markdown

markdown text

## encoding

encoding to use. Available type of encoding is same as [Encode](https://metacpan.org/pod/Encode) module.

# METHODS

## new

create Markdown::Pod object

## markdown\_to\_pod

convert markdown text to POD text

# SEE ALSO

- [Markdent](https://metacpan.org/pod/Markdent)
- [Pod::Markdown](https://metacpan.org/pod/Pod::Markdown)
- [Text::MultiMarkdown](https://metacpan.org/pod/Text::MultiMarkdown), [Text::Markdown](https://metacpan.org/pod/Text::Markdown)

# AUTHOR

Keedi Kim - 김도형 <keedi@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Keedi Kim.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
