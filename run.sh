#!/bin/bash

export test_typo3_branch
export test_no_tests_flag test_quiet_flag test_install_extbase_flag test_install_fluid_flag test_miau_flag

qprint() {
	if (( ${test_quiet_flag:-0} == 0 )) ; then
		echo $1
	fi
}

run() {
	qprint "Preparing tests"
	CWD=`pwd`
	prepare_files $CWD $1

	curl -sS https://getcomposer.org/installer | php

	php  -d apc.enable_cli=Off composer.phar install --dev

	cloneorupdate "${CWD}/Core" "git://git.typo3.org/TYPO3v4/Core.git" "${2}"
	cloneorupdate "${CWD}/t3/typo3conf/ext/phpunit" "git://git.typo3.org/TYPO3v4/Extensions/phpunit.git" "master"

	cd t3;
	[ ! -e typo3_src ] && ln -s ../Core typo3_src
	[ ! -e typo3 ] && ln -s typo3_src/typo3
	[ ! -e t3lib ] && ln -s typo3_src/t3lib
	[ ! -e index.php ] && ln -s typo3/index.php
	touch i.php

	if (( ${test_no_tests_flag:-0} == 1 )) ; then
		qprint "Preparation done"
	else
		qprint "Running the actual tests"
		cd $CWD
		vendor/bin/phpunit --verbose --testsuite "${1}_all"
	fi
}

usage() {
	printf "%b" "

You're doing it wrong.

Usage

  run.sh [options] [version]

Options

  [version]                            - Supports "4.7" / "6.0" and "master" for now

  --extension=<name>                    - The extension which should be tested
  --quiet                               - Avoid too much output
  --no-tests                            - Prepare everything but do not trigger the tests

  --install-extbase                     - Not implemented yet
  --install-fluid                       - Not implemented yet

"
}
cloneorupdate() {
	if [ ! -d $1 ] ; then
		git clone --recursive --quiet --branch $3 $2 $1
	else
		bash -c "cd $1 && git stash >/dev/null && git pull >/dev/null && git submodule update >/dev/null"
	fi
}

prepare_files() {
	mkdir -p "${1}/t3/typo3conf/ext"

############################ phpunit.xml ##############################

		cat > "${1}/phpunit.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<phpunit backupGlobals="false" backupStaticAttributes="false" processIsolation="false"
		 stopOnFailure="false" syntaxCheck="true" bootstrap="autoload.php"
EOF

	if (( ${test_miau_flag:-0} == 1 )) ; then
		cat >> "${1}/phpunit.xml" <<EOF
		 colors="true"
		 printerFile="vendor/whatthejeff/nyancat-phpunit-resultprinter/src/NyanCat/PHPUnit/ResultPrinter.php"
		 printerClass="NyanCat\PHPunit\ResultPrinter"
EOF
	fi
cat >> "${1}/phpunit.xml" <<EOF
	><testsuites>
		<testsuite name="${2}_all">
			<directory suffix="Test.php">t3/typo3conf/ext/${2}/Tests/Unit</directory>
		</testsuite>
	</testsuites>
</phpunit>
EOF

##########################################################

	\curl -sSL http://localhost/continuousintegration/res/composer.json > "${1}/composer.json"
	\curl -sSL http://localhost/continuousintegration/res/LocalConfiguration.php_ > "${1}/t3/typo3conf/LocalConfiguration.php"
	\curl -sSL http://localhost/continuousintegration/res/localconf.php_ > "${1}/t3/typo3conf/localconf.php"

	case "$test_typo3_branch" in

		TYPO3_4-7|TYPO3_4-6|TYPO3_4-5)
				\curl -sSL http://localhost/continuousintegration/res/autoload_4.7.php_ > "${1}/autoload.php" ;;

		*)
				\curl -sSL http://localhost/continuousintegration/res/autoload.php_ > "${1}/autoload.php" ;;
	esac

	sed -i -e "s~###path###~${1}~g" "${1}/t3/typo3conf/LocalConfiguration.php"
	sed -i -e "s~###path###~${1}~g" "${1}/t3/typo3conf/localconf.php"
	sed -i -e "s~###path###~${1}~g" "${1}/autoload.php"
	sed -i -e "s~###ext###~${2}~g" "${1}/t3/typo3conf/LocalConfiguration.php"
	sed -i -e "s~###ext###~${2}~g" "${1}/t3/typo3conf/localconf.php"

##########################################################
}


# Parse CLI arguments.
while (( $# > 0 )) ; do
	token="${1#--}"
	shift
	case "$token" in
		extension=*)
			export "test_extension"="${token/extension=/}"
		;;

		no-tests|quiet|install-extbase|install-fluid|miau)
			export "test_${token/-/_}_flag"=1
		;;

		4.5|4.6|4.7|6.0)
			export "test_typo3_branch"="TYPO3_${token/\./-}"
		;;
		master)
			export "test_typo3_branch"="${token}"
		;;

		*)
			usage
			exit 1
		;;
	esac
done

run "$test_extension" "$test_typo3_branch"