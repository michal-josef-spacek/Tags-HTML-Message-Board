use strict;
use warnings;

use CSS::Struct::Output::Structure;
use English;
use Error::Pure::Utils qw(clean);
use Tags::HTML::Message::Board;
use Tags::Output::Structure;
use Test::MockObject;
use Test::More 'tests' => 10;
use Test::NoWarnings;

# Test.
my $obj = Tags::HTML::Message::Board->new(
	'tags' => Tags::Output::Structure->new,
);
isa_ok($obj, 'Tags::HTML::Message::Board');

# Test.
$obj = Tags::HTML::Message::Board->new(
	'css' => CSS::Struct::Output::Structure->new,
	'tags' => Tags::Output::Structure->new,
);
isa_ok($obj, 'Tags::HTML::Message::Board');

# Test.
eval {
	Tags::HTML::Message::Board->new(
		'css' => Test::MockObject->new,
		'tags' => Tags::Output::Structure->new,
	);
};
is(
	$EVAL_ERROR,
	"Parameter 'css' must be a 'CSS::Struct::Output::*' class.\n",
	"Bad 'CSS::Struct::Output' instance.",
);
clean();

# Test.
eval {
	Tags::HTML::Message::Board->new(
		'lang' => 'xxx',
	);
};
is($EVAL_ERROR, "Parameter 'lang' doesn't contain valid ISO 639-2 code.\n",
	"Parameter 'lang' doesn't contain valid ISO 639-2 code.");
clean();

# Test.
eval {
	Tags::HTML::Message::Board->new(
		'tags' => 0,
	);
};
is(
	$EVAL_ERROR,
	"Parameter 'tags' must be a 'Tags::Output::*' class.\n",
	"Missing required parameter 'tags'.",
);
clean();

# Test.
eval {
	Tags::HTML::Message::Board->new(
		'tags' => Test::MockObject->new,
	);
};
is(
	$EVAL_ERROR,
	"Parameter 'tags' must be a 'Tags::Output::*' class.\n",
	"Bad 'Tags::Output' instance.",
);
clean();

# Test.
eval {
	Tags::HTML::Message::Board->new(
		'text' => undef,
	);
};
is($EVAL_ERROR, "Parameter 'text' is required.\n",
	"Parameter 'text' is required.");
clean();

# Test.
eval {
	Tags::HTML::Message::Board->new(
		'text' => [],
	);
};
is($EVAL_ERROR, "Parameter 'text' must be a hash with language texts.\n",
	"Parameter 'text' must be a hash with language texts.");
clean();

# Test.
eval {
	Tags::HTML::Message::Board->new(
		'text' => {},
	);
};
is($EVAL_ERROR, "Texts for language 'eng' doesn't exist.\n",
	"Texts for language 'eng' doesn't exist.");
clean();
