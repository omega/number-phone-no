use inc::Module::Install;

name 'Number-Phone-NO';
all_from 'lib/Number/Phone/NO.pm';

build_requires 'Test::More';
requires 'DBM::Deep' => '1.0';
requires 'Number::Phone' => '1.0';
requires 'Scalar::Util' => 0;
requires 'Carp' => 0;

auto_install;

WriteAll;

