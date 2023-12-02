#!/usr/bin/env perl

=head1 NAME

issue - Manage issues and directories

=head1 SYNOPSIS

issue [subcommand]

=head1 DESCRIPTION

The 'issue' script provides a set of subcommands to manage issues and
directories related to a project.

=head1 SUBCOMMANDS

=over 4

=item edit

    Edit and create an issue. Opens the default editor for creating or editing an issue.

=item init

    Initialize the issue directory structure. Creates the 'issue' directory with subdirectories 'closed', 'backlog', 'active'.

=item list (or ls)

    List all files in the issue directory and its subdirectories.

=item dir

    Print the parent directory where the issues are located.

=item open

    Open an issue file for editing. If the file is saved, it is stored in the 'issue/open' directory with a unique filename based on the issue title.

=item categories

    List absolute paths of all subdirectories in the 'issue' directory.

=item search

    Perform a search (placeholder for future functionality).

=item status

    Display the status of each subdirectory in the 'issue' directory, showing the number of files in each.

=item validate

    Validate commit messages in '.md' files within the 'issue' directory. Prints 'valid' or 'invalid' for each file.

=item show

    Display the status of each subdirectory in the 'issue' directory, showing the number of files in each.

=back

=head1 AUTHOR

Bassim Huis

=cut

use strict;
use warnings;

use Cwd;
use File::Find;
use File::Path qw(make_path);
use File::Spec;
use Getopt::Long;
use File::Temp;
use File::Copy;
use File::Basename;

# Helper function to create a safe filename
sub safe_filename {
    my $title = shift;
    $title =~ s/[^\w.-]/_/g;
    lc $title;
}

sub print_html_issues {
  use Text::Markdown 'markdown';

  my @lanes_list = lanes_list();
  my $parent_directory = issue_dir();

  for my $open_directory (@lanes_list) {
    my $directory_name = basename($open_directory);

    opendir(my $dh, $open_directory) or die "Cannot open directory $open_directory: $!";

    my @issue_files = grep { /\.md$/ && -f File::Spec->catfile($open_directory, $_) } readdir($dh);
    closedir($dh);

    # print "<details><summary>$open_directory</summary>\n";

    # print "<h2>$directory_name</h2>";


    if (@issue_files) {
      foreach my $issue_file (@issue_files) {
        my $file_path = File::Spec->catfile($open_directory, $issue_file);

        open my $filehandle, '<', $file_path or die "Cannot open file $file_path for reading: $!";
        my $issue_content = do { local $/; <$filehandle> };
        close $filehandle;

        my ($issue_title) = $issue_content =~ /^([^\n]+)/;
        $issue_title ||= "Untitled Issue";

        $issue_title = safe_filename($issue_title);

        my $relative_path = File::Spec->abs2rel($file_path, $parent_directory);

        print '<article class="issue-issue">';
        print "<a class='issue-bookmark' id='$issue_title' href='#$issue_title'>🔖 /$relative_path</a>";

        # $issue_content =~ s/\b(\w+)#\b/<a href="#$1">#$1<\/a>/g;

        $issue_content =~ s/\s([\w-]+)#/<a class="issue-hash" title="Search hashtag $1#" href="#">$1#<\/a>/g;
        $issue_content =~ s/\s(@[\w-]+)/<a class="issue-mention" title="Search mention $1" href="#">$1<\/a>/g;
        $issue_content =~ s/\s(\/[\w-]+)/<a class="issue-directory" title="Search directory $1" href="#">$1<\/a>/g;

        print markdown($issue_content), '</article>';
      }

    } else {
      # print "No open issues found.\n";
    }
    # print "</details>\n";
  }
}

sub print_html_issues_with_template {
    my $template_path = parent_dir() . '/lib/issue_lib/resources/template.html';

    # Read the content of the template file
    open my $fh, '<', $template_path or die "Cannot open file $template_path: $!";
    my $template_content = do { local $/; <$fh> };
    close $fh;

    # Split the template file on <!--issues-->
    my ($before_issues, $after_issues) = split /<!--issues-->/, $template_content, 2;

    # Print the part before the <!--issues--> comment
    print $before_issues;

    # Call the subroutine to print issues
    print_html_issues();

    # Print the part after the <!--issues--> comment
    print $after_issues;
}

sub find_parent_directory_with_file {
    my ($start_directory, $target_file) = @_;

    # Get the absolute path of the input directory
    my $absolute_path = File::Spec->rel2abs($start_directory);

    # Iterate through each parent directory
    while (length($absolute_path) > 1) {  # Stop when we reach the root directory
        # Check if the target file exists in the current directory
        my $target_path = File::Spec->catfile($absolute_path, $target_file);
        return $absolute_path if -d $target_path;

        # Move up one level in the directory structure
        my @dirs = File::Spec->splitdir($absolute_path);
        $absolute_path = File::Spec->catdir(@dirs[0 .. $#dirs - 1]);
    }

    # If we reach here, the file was not found in any parent directory
    return undef;
}

sub parent_dir {
  my $start_directory = getcwd();
  my $target_file = 'issue';

  find_parent_directory_with_file($start_directory, $target_file);
}

sub open_issue {
  # Create a temporary file with a random name and .md extension
  my ($fh, $filename) = File::Temp::tempfile(
    'issue/tmp-XXXX',
    SUFFIX => '.md'
  );
  close $fh;

  # Open the temporary file with the default editor
  my $editor = $ENV{EDITOR} || 'vi';  # Use vi if EDITOR is not set
  system("$editor $filename");

  # Check if the file was saved
  if (-e $filename) {
    # Read the content of the saved file
    open my $filehandle, '<', $filename or die "Cannot open file $filename for reading: $!";
    my $issue_content = do { local $/; <$filehandle> };
    close $filehandle;

    # Extract the title from the contents (first line)
    my ($issue_title) = $issue_content =~ /^([^\n]+)/;
    if (!$issue_title) {
      print "Cannot create an issue without a title.\n";
      exit 1;
    }

    # Remove leading and trailing whitespaces from the title
    $issue_title =~ s/^\s+|\s+$//g;

    # Create the issue/open directory if it doesn't exist
    my $open_directory = File::Spec->catdir('issue', 'open');
    mkdir $open_directory unless -e $open_directory;

    # Create a safe filename based on the extracted title
    my $safe_filename = File::Spec->catfile($open_directory, safe_filename($issue_title) . '.md');

    # Check for filename conflicts and append a counter if necessary
    my $counter = 1;
    my $original_safe_filename = $safe_filename;
    while (-e $safe_filename) {
      print "Possible duplicate issue found:\t$safe_filename.\n";
      $safe_filename = $original_safe_filename;
      $safe_filename =~ s/\.md$/_$counter.md/;
      $counter++;
    }

    print "Moving $filename to $safe_filename.\n";
    move($filename, $safe_filename) or die "Move operation failed: $!";

    # Print a message indicating where the file is saved
    print "Issue saved at: $safe_filename\n";
  } else {
    print "No changes were saved.\n";
  }
}

sub issue_dir {
  my $dir = parent_dir();
  "$dir/issue";
}

sub dir {
  my $parent_directory = parent_dir();

  if (not defined $parent_directory) {
    exit 1;
  }

  print "$parent_directory\n";
}

sub edit {
    print "Executing 'edit' subcommand\n";
}

sub mkdir_p {
    my $base_directory = shift;

    foreach my $subdir (@_) {
        my $subdir_path = File::Spec->catdir($base_directory, split('/', $subdir));
        make_path($subdir_path) if !-e $subdir_path;
        print "Created\t$subdir_path\n"
    }
}

sub init {
  my $start_directory = getcwd();
  print "In\t$start_directory\n";
  mkdir_p('issue', 'closed', 'backlog', 'active');
}

sub list {
  my $root_directory = issue_dir();

  # Subroutine to process each file
  my $process_file = sub {
      my $file = $File::Find::name;

      return if -d $file;

      return unless $file =~ /\.md$/i;

      print "$file\n";
  };

  # Traverse the directory and its subdirectories
  find($process_file, $root_directory);
}

sub lanes_list {
  # Specify the directory you want to search
  my $directory = issue_dir();

  # Array to store the list of directories
  my @directories;

  # Use the find function from File::Find
  find(sub {
      # Check if the current item is a directory and not equal to the top-level directory
      if (-d $_ && $_ ne $directory && $_ ne '.') {
        push @directories, $File::Find::name;
      }
    }, $directory);

  # Define the callback function for find
  return @directories;
}

sub categories {
  print "$_\n" for lanes_list()
}

sub search {
    print "Executing 'search' subcommand\n";
}

sub status {
  # Specify the root directory
  my $root_directory = issue_dir();

  # Open the root directory
  opendir(my $dh, $root_directory) or die "Cannot open directory: $!";

  # Read the entries from the root directory
  while (my $entry = readdir($dh)) {
    next if $entry eq '.' || $entry eq '..';  # Skip '.' and '..'

    my $absolute_path = File::Spec->catfile($root_directory, $entry);

    # Count the number of files in the directory
    my $file_count = scalar(grep { -f $_ } glob("$absolute_path/*"));

    # Print the result
    print "$absolute_path\t$file_count\n";
  }

  # Close the directory handle
  closedir($dh);
}

sub is_valid_commit_message {
    my $commit_message = shift;

    # Split the commit message into lines
    my @lines = split /\n/, $commit_message;

    # Check if the first line is defined (not empty)
    defined $lines[0];
}

sub is_valid_commit_message_from_file {
    my $file_path = shift;

    # Read the content of the file
    open my $fh, '<', $file_path or die "Cannot open file '$file_path' for reading: $!";
    my $commit_message = do { local $/; <$fh> };
    close $fh;

    # Call the original function with the content of the file
    is_valid_commit_message($commit_message);
}

sub validate {
  my $root_directory = issue_dir();
  my $exit_code = 0;

  find(sub {
    return if -d $_ || $_ !~ /\.md$/i;

    my $absolute_path = File::Spec->rel2abs($_);

    if (is_valid_commit_message_from_file($_)) {
      print "valid\t$absolute_path\n";
    } else {
      print "invalid\t$absolute_path\n";
      $exit_code = 1;
    }
  }, $root_directory);

  exit $exit_code;
}

sub show {
    print "Executing 'show' subcommand\n";
}

sub display_help {
    print "Usage: $0 <subcommand>\n";
    print "Subcommands:\n";
    print "  edit\n";
    print "  init\n";
    print "  list\n";
    print "  ls\n";
    print "  dir\n";
    print "  search\n";
    print "  status\n";
    print "  show\n";
    exit 1;
}

# Define the available subcommands
my %subcommands = (
    'html'     => \&print_html_issues_with_template,
    'categories'    => \&categories,
    'validate' => \&validate,
    'edit'     => \&edit,
    'init'     => \&init,
    'list'     => \&list,
    'ls'       => \&list,
    'dir'      => \&dir,
    'open'     => \&open_issue,
    'search'   => \&search,
    'status'   => \&status,
    'show'     => \&show,
);

# Get the subcommand from the command line
my $subcommand = shift @ARGV;

GetOptions('subcommand=s' => \$subcommand);

# If no subcommand is provided or it's not recognized, display help
unless ($subcommand && $subcommands{$subcommand}) {
    display_help();
}

# Execute the selected subcommand
$subcommands{$subcommand}->();
