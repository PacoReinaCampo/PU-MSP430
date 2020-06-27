#!/bin/bash

###############################################################################
#                                                                             #
#                PARSE REGRESSION RESULTS IN THE LOG DIRECTORY                #
#                                                                             #
###############################################################################

#----------------------------------------------------#
# Get numbers of PASSED/SKIPPED/FAILED/ABORDED tests #
#----------------------------------------------------#

passed_nr="0"
skipped_nr="0"
failed_nr="0"
aborded_nr="0"

for file in ./log/*.log ; do
    passed_ok=`grep -c PASSED $file`
    skipped_ok=`grep -c SKIPPED $file`
    failed_ok=`grep -c FAILED $file`
    
    if [ $passed_ok == 1 ]; then 
	passed_nr=`expr $passed_nr + 1`
    elif [ $skipped_ok == 1 ]; then 
	skipped_nr=`expr $skipped_nr + 1`
    elif [ $failed_ok == 1 ]; then 
	failed_nr=`expr $failed_nr + 1`
    else
	aborded_nr=`expr $aborded_nr + 1`
    fi
done

#----------------------------------------------------#
# Display detailed report                            #
#----------------------------------------------------#
echo ""
echo "#----------------------------------------------------#"
echo "#                   DETAILED REPORT                  #"
echo "#----------------------------------------------------#"
echo ""
if [ $skipped_nr != 0 ]; then 
    echo " SKIPPED TESTS:"
    for file in ./log/*.log ; do
	skipped_ok=`grep -c SKIPPED $file`
	if [ $skipped_ok == 1 ]; then 
	    echo "               -  $file"
	fi
    done
fi
echo ""
if [ $failed_nr != 0 ]; then 
    echo -e "\e[01;31m FAILED TESTS:\e[00m"
    for file in ./log/*.log ; do
	failed_ok=`grep -c FAILED $file`
	if [ $failed_ok == 1 ]; then 
	    echo -e "\e[01;31m               -  $file \e[00m"
	fi
    done
fi
echo ""
if [ $aborded_nr != 0 ]; then 
    echo -e "\e[01;31m ABORDED TESTS:\e[00m"
    for file in ./log/*.log ; do
	passed_ok=`grep -c PASSED $file`
	if [ $passed_ok == 0 ]; then 
	    failed_ok=`grep -c FAILED $file`
	    if [ $failed_ok == 0 ]; then 
		skipped_ok=`grep -c SKIPPED $file`
		if [ $skipped_ok == 0 ]; then 
		    echo -e "\e[01;31m               -  $file \e[00m"
		fi
	    fi
	fi
    done
fi
echo ""

#----------------------------------------------------#
# Display summary report                             #
#----------------------------------------------------#
echo ""
echo "#----------------------------------------------------#"
echo "#                    SUMMARY REPORT                  #"
echo "#----------------------------------------------------#"
echo ""

# Generate final report
echo    "     +-----------------------------------"
echo -e "     | Number of PASSED  tests :\e[01;32m $passed_nr \e[00m"
echo -e "     | Number of SKIPPED tests :\e[01;32m $skipped_nr \e[00m"
echo -e "     | Number of FAILED  tests :\e[01;31m $failed_nr \e[00m"
echo -e "     | Number of ABORDED tests :\e[01;31m $aborded_nr \e[00m"
echo    "     |----------------------------------"
echo -n "     | Number of tests         : "
ls -1 ./log/*.log | wc -l
echo    "     +----------------------------------"
echo    ""
echo    "      Make sure passed+skipped == total"
echo    ""
echo    ""
