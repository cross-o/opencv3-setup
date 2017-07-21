#!/bin/bash
# Script to assist with installing sonic-track and OpenCV3
# If problems are encountered exit to command to try to resolve
# Then retry menu pick again or continue to next step
# version 0.32

function do_anykey ()
{
   echo "------------------------------"
   echo "  Review messages for Errors"
   echo "  Exit to Console to Resolve"
   echo "------------------------------"   
   read -p "m)enu e)xit ?" choice
   case "$choice" in
      m|M ) echo "Back to Main Menu"
       ;;
      e|E ) echo "Install Aborted. Bye"
            exit 1
       ;;
        * ) echo "invalid Selection"
            exit 1
       ;;
   esac
}

function do_rpi_update ()
{
   cd ~   
   # Update Raspbian to Lastest Releases
   echo "Updating Raspbian Please Wait ..."
   echo "---------------------------------"    
   sudo apt-get update
   echo "Done Raspbian Update ...."
   echo "Upgrading Raspbian Please Wait ..."
   echo "---------------------------------"    
   sudo apt-get upgrade
   echo "Done Raspbian Upgrade ..."
   echo ""
   echo "After a Reboot rerun this script and Select"
   echo "Menu Pick: OpenCV 3.2.0 Install Build Dependencies and Download Source"
   echo "-----------------------------------------------------------------------"
   echo "If there were Significant Changes then Reboot Recommended"
   echo ""   
   read -p "Reboot Now? (y/n)?" choice
   case "$choice" in 
     y|Y ) echo "yes"
           echo "Rebooting Now"
           sudo reboot
           ;;
     n|N ) echo "Back To Main Menu"
           ;;
       * ) echo "invalid Selection"
           exit 1
           ;;
  esac
}

function do_cv3_dep ()
{
   cd ~/
   # Install opencv3 build dependencies
   echo "Installing opencv 3.2.0 build and run dependencies"
   echo "--------------------------------------------------"  
   sudo apt-get install -y build-essential cmake pkg-config
   sudo apt-get install -y libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev
   sudo apt-get install -y libgtk2.0-dev libgstreamer0.10-0-dbg libgstreamer0.10-0 libgstreamer0.10-dev libv4l-0 libv4l-dev
   sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
   sudo apt-get install -y libxvidcore-dev libx264-dev
   sudo apt-get install -y libatlas-base-dev gfortran
   sudo apt-get install -y python-numpy python-scipy python-matplotlib
   sudo apt-get install -y default-jdk ant
   sudo apt-get install -y libgtkglext1-dev
   sudo apt-get install -y v4l-utils
   wget https://bootstrap.pypa.io/get-pip.py
   sudo python get-pip.py   
   sudo apt-get install -y python2.7-dev   
   sudo pip install numpy 
   echo "Done Install of Build Essentials and Dependencies ..."
   echo "-----------------------------------------------------"    
   echo "Download and unzip opencv 3.2.0 Source Files"
   echo "-----------------------------------------------------"    
   wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.2.0.zip
   unzip opencv.zip
   wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.2.0.zip   
   unzip opencv_contrib.zip   
   echo "Done Install of Build Essentials, Dependencies and OpenCV 3.2.0 Source."
   echo "Next Step Select Menu Pick:  OpenCV3 3.2.0 Make, Compile and Install"    
   do_anykey
}

function do_cv3_install ()
{
   cd ~
   echo "Running cmake prior to compiling opencv 3.2.0"
   echo "---------------------------------------------"
   echo "This will take a few minutes ...."   
   cd ~/opencv-3.2.0/
   if [ ! -d "build" ]; then
     mkdir build
   fi
   cd build
   cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.2.0/modules \
	-D BUILD_EXAMPLES=ON \
	-D ENABLE_NEON=ON .. 
    
    echo "---------------------------------------" 
    echo " Review cmake messages above for Errors"
    echo "---------------------------------------" 
    echo "n exits to console"
    read -p "Was cmake successful y/n ?" choice
    case "$choice" in
        y|Y ) echo "Compile of openCV ver 3.2.0 will take approx 3 to 4 hours ...."
              echo "NOTE"
              echo "If single core Edit this script to change line 125 to remove -j2" 
              echo "----------------------------------------------------------------"
              echo "Once Compile is started go for a nice long walk"
              echo "or Binge watch Game of Thrones or Something Else....."
              echo ""              
              echo "Run make -j2  (using 2 of 4 cpu cores)"
              read -p "Press Enter to Begin Compiling"             
              make -j2
              echo "--------------------------------------------"  
              echo " Check above for Compile Errors"
              echo "--------------------------------------------"               
              echo "If OK Reboot to Complete Install of OpenCV"
              echo "If Errors Please Investigate Problem"
              do_anykey
              ;;
        n|N ) echo "If cmake Failed. Investigate Problem and Try again"
              exit 1
              ;;
          * ) echo "invalid Selection"
              do_anykey
              ;;
    esac
}


#------------------------------------------------------------------------------
function do_about()
{
  whiptail --title "About" --msgbox " \
                OpenCV 3.2.0 Install Menu Assist
                  written by Claude Pageau

This Menu will help install opencv 3.2.0 if required
You will be asked to reboot during installation.

Run Menu Pick Selections in order and verify successful completion
before progressing to next step.  This install is configured for
a multicore Raspberry Pi make -j2.  Modify this script  at
approx line 125 and remove -j2 after the make command.

For Additional Details See https://github.com/pageauc/opencv3-setup

Script Steps Based on GitHub Repo 
https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi

             Good Luck
            
\
" 35 70 35
}


#------------------------------------------------------------------------------
function do_main_menu ()
{
  SELECTION=$(whiptail --title "opencv 3.2.0 Install Assist" --menu "Arrow/Enter Selects or Tab Key" 20 70 10 --cancel-button Quit --ok-button Select \
  "a " "Raspbian Jessie Update and Upgrade" \
  "b " "OpenCV 3.2.0 Install Build Dependencies and Download Source" \
  "c " "OpenCV 3.2.0 cmake, make (compile) and make install" \
  "d " "About" \
  "q " "Quit Menu Back to Console"  3>&1 1>&2 2>&3)

  RET=$?
  if [ $RET -eq 1 ]; then
    exit 0
  elif [ $RET -eq 0 ]; then
    case "$SELECTION" in
      a\ *) do_rpi_update ;;
      b\ *) do_cv3_dep ;;
      c\ *) do_cv3_install ;; 
      d\ *) do_about ;;
      q\ *) echo "After OpenCV 3.2.0 Installation is Complete"
            echo "Reboot to Finalize Install of Opencv"
            echo "Then Test OpenCV"
            echo "Good Luck ..."
            exit 0 ;;
         *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running selection $SELECTION" 20 60 1
  fi
}

while true; do
   do_main_menu
done
