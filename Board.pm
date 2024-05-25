package Tags::HTML::Message::Board;

use base qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params split_params);
use Data::HTML::Element::Textarea;
use Mo::utils 0.06 qw(check_bool check_required);
use Mo::utils::CSS 0.02 qw(check_css_class);
use Error::Pure qw(err);
use Readonly;
use Scalar::Util qw(blessed);
use Tags::HTML::Element::Textarea;

Readonly::Scalar our $CSS_CLASS_ADD_COMMENT => 'add-comment';

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my ($object_params_ar, $other_params_ar) = split_params(
		['css_class', 'lang', 'mode_comment_form', 'text'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# CSS class.
	$self->{'css_class'} = 'message-board';

	# Language.
	$self->{'lang'} = 'eng';

	# Mode for comment form.
	$self->{'mode_comment_form'} = 1;

	# Language texts.
	$self->{'text'} = {
		'eng' => {
			'add_comment' => 'Add comment',
			'author' => 'Name of author',
			'date' => 'Date',
		},
	};

	# Process params.
	set_params($self, @{$object_params_ar});

	# Check 'css_class'.
	check_required($self, 'css_class');
	check_css_class($self, 'css_class');

	# Check 'mode_comment_form'.
	check_required($self, 'mode_comment_form');
	check_bool($self, 'mode_comment_form');

	$self->{'_tags_textarea'} = Tags::HTML::Element::Textarea->new(
		'css' => $self->{'css'},
		'tags' => $self->{'tags'},
	);
	my $data_textarea = Data::HTML::Element::Textarea->new(
		'autofocus' => 1,
		'rows' => 6,
	);
	$self->{'_tags_textarea'}->init($data_textarea);

	# Object.
	return $self;
}

sub _cleanup {
	my $self = shift;

	delete $self->{'_board'};

	return;
}

sub _init {
	my ($self, $board) = @_;

	if (! defined $board
		|| ! blessed($board)
		|| ! $board->isa('Data::Message::Board')) {

		err 'Data object for message board is not valid.';
	}

	$self->{'_board'} = $board;

	return;
}

sub _process {
	my $self = shift;

	if (! exists $self->{'_board'}) {
		return;
	}

	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'class', $self->{'css_class'}],
	);
	$self->_tags_message($self->{'_board'}, 'main-message');

	# Comments.
	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'class', 'comments'],
	);
	foreach my $comment (@{$self->{'_board'}->comments}) {
		$self->_tags_message($comment, 'comment');
	}
	$self->{'tags'}->put(
		['e', 'div'],
	);

	if ($self->{'mode_comment_form'}) {
		$self->{'tags'}->put(
			['b', 'div'],
			['a', 'class', $CSS_CLASS_ADD_COMMENT],
			['b', 'div'],
			['a', 'class', 'title'],
			['d', $self->_text('add_comment')],
			['e', 'div'],
		);
		$self->{'_tags_textarea'}->process;
		$self->{'tags'}->put(
			['e', 'div'],
		);
	}

	$self->{'tags'}->put(
		['e', 'div'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	$self->{'css'}->put(
		['s', '.'.$self->{'css_class'}.' .main-message'],
		['d', 'border', '1px solid #ccc'],
		['d', 'padding', '20px'],
		['d', 'border-radius', '5px'],
		['d', 'background-color', '#f9f9f9'],
		['d', 'max-width', '600px'],
		['d', 'margin', 'auto'],
		['e'],

		['s', '.'.$self->{'css_class'}.' .comments'],
		['d', 'max-width', '600px'],
		['d', 'margin', 'auto'],
		['e'],

		['s', '.'.$self->{'css_class'}.' .comment'],
		['d', 'border-left', '2px solid #ccc'],
		['d', 'padding-left', '10px'],
		['d', 'margin-top', '20px'],
		['d', 'margin-left', '10px'],
		['e'],

		['s', '.author'],
		['d', 'font-weight', 'bold'],
		['d', 'font-size', '1.2em'],
		['e'],

		['s', '.comment .author'],
		['d', 'font-size', '1em'],
		['e'],

		['s', '.date'],
		['d', 'color', '#555'],
		['d', 'font-size', '0.9em'],
		['d', 'margin-bottom', '10px'],
		['e'],

		['s', '.comment .date'],
		['d', 'font-size', '0.8em'],
		['e'],

		['s', '.text'],
		['d', 'margin-top', '10px'],
		['e'],
	);
	if ($self->{'mode_comment_form'}) {
		$self->{'css'}->put(
			['s', '.'.$self->{'css_class'}.' .'.$CSS_CLASS_ADD_COMMENT],
			['d', 'max-width', '600px'],
			['d', 'margin', 'auto'],
			['e'],

			['s', '.'.$self->{'css_class'}.' .'.$CSS_CLASS_ADD_COMMENT.' .title'],
			['d', 'margin-top', '20px'],
			['d', 'font-weight', 'bold'],
			['d', 'font-size', '1.2em'],
			['e'],
		);
		$self->{'_tags_textarea'}->process_css;
	}

	return;
}

sub _tags_message {
	my ($self, $obj, $class) = @_;

	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'class', $class],

		['b', 'div'],
		['a', 'class', 'author'],
		['d', $self->_text('author').': '.$obj->author->name],
		['e', 'div'],

		['b', 'div'],
		['a', 'class', 'date'],
		['d', $self->_text('date').': '.$obj->date->dmy('.').' '.$obj->date->hms],
		['e', 'div'],

		['b', 'div'],
		['a', 'class', 'text'],
		['d', $obj->message],
		['e', 'div'],

		['e', 'div'],
	);

	return;
}

sub _text {
	my ($self, $key) = @_;

	if (! exists $self->{'text'}->{$self->{'lang'}}->{$key}) {
		err "Text for lang '$self->{'lang'}' and key '$key' doesn't exist.";
	}

	return $self->{'text'}->{$self->{'lang'}}->{$key};
}

1;
