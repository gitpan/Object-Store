use ExtUtils::MakeMaker;
WriteMakefile (
    'NAME'		=> 'Object::Store',
    'VERSION_FROM'	=> 'lib/Object/Store.pm',
    'PREREQ_PM'		=> {
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM => 'lib/Object/Store.pm', # retrieve abstract from module
       AUTHOR     => 'Jean-Michel Hiver') : ()),
);


1;


package MY;


sub postamble {
    return <<EOF;
cover ::
	\$(RM_RF) cover_db
	PERL5OPT=-MDevel::Cover \$(MAKE) test || true
	cover -report html cover_db > /dev/null

EOF

}


1;
