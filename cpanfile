requires "Carp" => "0";
requires "Clone" => "0";
requires "File::HomeDir" => "0";
requires "Hash::Diff" => "0";
requires "Hash::Merge" => "0";
requires "IPC::Open3" => "0";
requires "IPC::Run3" => "0";
requires "JSON" => "0";
requires "List::AllUtils" => "0";
requires "List::Util" => "0";
requires "Module::Runtime" => "0";
requires "Moo" => "0";
requires "Moo::Role" => "0";
requires "MooseX::App" => "0";
requires "MooseX::App::Command" => "0";
requires "MooseX::MungeHas" => "0";
requires "Path::Tiny" => "0";
requires "Symbol" => "0";
requires "Try::Tiny" => "0";
requires "experimental" => "0";
requires "namespace::clean" => "0";
requires "overload" => "0";
requires "perl" => "v5.20.0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::MockObject::Extends" => "0";
  requires "Test::More" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Test::More" => "0.96";
  requires "Test::Vars" => "0";
};
