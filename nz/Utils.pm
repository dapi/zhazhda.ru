package nz::Utils;
use strict;
use dpl::System;
use dpl::Context;
use Exporter;
use vars qw(@ISA
            @EXPORT);
@ISA = qw(Exporter);

@EXPORT = qw(forum
             files_holder);


sub forum { setting('forum'); }
sub files_holder { setting('forum')->files_holder(); }
#sub journal { context('journal_instance'); }

1;
