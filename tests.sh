#!/do/not/execute

run_test() {
	r2args="${r2} -e scr.color=0 -N -q -i ${rad} ${ARGS} ${FILE}"

	# ${FILTER} can be used to filter out random results to create stable
	# tests.
	if [ -n "${FILTER}" ]; then
		r2args="${r2args} 2>&1 | ${FILTER} > ${out}"
	else
		r2args="${r2args} > ${out} 2>&1"
	fi

	if [ -n "${VALGRIND}" ]; then
		cmd="valgrind --error-exitcode=47 --log-file=${val} ${r2args}"
	else
		cmd="${r2args}"
	fi
	cmd="echo q | ${cmd}"

	file=`basename $0`
	if [ -z "${NAME}" ]; then
		NAME=$file
	else
		NAME="$file: $NAME"
	fi

	echo "Next Test: ${NAME}"
	echo "Running: ${cmd}"
	NAME=

	# put expected outcome and program to run in files
	echo "${CMDS}" > ${rad}
	echo "${EXPECT}" > ${exp}

	eval ${cmd}
	code=$?
	if [ ${code} -eq 47 ]; then
		printf "\033[31m"
		echo "FAIL (Valgrind error)"
		printf "\033[0m"
		cat ${val}
		[ -z "${NOEXIT}" ] && exit ${code}
	elif [ ! ${code} -eq 0 ]; then
		printf "\033[31m"
		echo "FAIL (Radare2 crashed?)"
		printf "\033[0m"
		[ -z "${NOEXIT}" ] && exit ${code}
	elif [ "`cat $out`" = "${EXPECT}" ]; then
		printf "\033[32m"
		echo "SUCCESS"
		printf "\033[0m"
	else
		printf "\033[31m"
		echo "FAIL (Unexpected outcome)"
		printf "\033[0m"
		diff -u ${exp} ${out}
		[ -z "${NOEXIT}" ] && exit 1
	fi
	rm -f ${out} ${val} ${rad} ${exp}
	echo "-------------------------------------------------------------------"
}

r2=${R2}
if [ -z "${R2}" ]; then
	r2=`which radare2`
fi

out=`mktemp out.XXXXXX`
val=`mktemp val.XXXXXX`
rad=`mktemp rad.XXXXXX`
exp=`mktemp exp.XXXXXX`
