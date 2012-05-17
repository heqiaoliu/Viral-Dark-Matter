#####################
# mdce_def
# This file contains the definitions and the defaults for the mdce service and
# the processes it manages.  The file is read only when starting and stopping
# the mdce service, or when running the mdce service command with the
# following arguments: status, restart, and console.
# When workers and job managers are started and stopped, they contact the mdce
# service they are running under to obtain the values of the definitions and
# defaults stored in this file.  Thus, this file is not read again when 
# starting and stopping workers and job managers.
# We recommend using a single mdce_def file for all the job managers and
# workers in your cluster, in order to ensure that they are set up in a 
# consistent manner.
####################

# Copyright 2004-2010 The MathWorks, Inc.


########
#
# MDCE Process and Logging
#
########

# HOSTNAME: The name of the host reading this file.
# Only change this line if the hostname command is unavailable, if the
# hostname command returns an incorrect host name, or if it returns a host
# name that cannot be resolved by all the other computers that the MDCE
# processes will communicate with.
# All the MDCE processes will advertise themselves using this host name.
# The job manager must be able to resolve the host name that the MATLAB
# workers advertise, and all MATLAB workers and clients must be able to
# resolve the host name that the job manager advertises.
HOSTNAME=`hostname`

# BASE_PORT: The base port of the mdce service.
# The mdce service will use as many ports as needed, starting with BASE_PORT.
# On a machine that runs a total of nJ job managers and nW workers, the mdce
# service reserves a total of 5+nJ+3*nW consecutive ports for its own use.
# All job managers and workers, even those on different hosts, that are going
# to work together must use the same base port, otherwise they will not be
# able to contact each other. In addition MPI communication will occur on ports 
# starting at BASE_PORT+1000 and using up nW consecutive ports.
# Some operating systems are reluctant to immediately free TCP ports from the
# TIME_WAIT state for use by the same or other processes, so you should allow
# unfirewalled communication on 2*nW ports for MPI communications.
BASE_PORT="27350"

# MDCEUSER: The username under which the mdce service starts.
# If empty, the mdce service runs as the user that starts the service.
# All the processes that the mdce service manages use the same username as
# the mdce service itself.
#
# The instructions recommend using root to start the mdce service.
MDCEUSER=""

# PIDBASE and LOCKBASE: The directories that will be used to hold the PID and 
# lock for the mdce service. 
# These directories usually require root access to write to. The LOCKBASE is 
# only used on REDHAT type systems that operate on both a PID file and a 
# subsystem 'touched' file.
PIDBASE="/var/run"
LOCKBASE="/var/lock/subsys"

# LOGBASE: The directory in which all logfiles should be written.  
# The user the mdce service runs as must have write access to this directory.
LOGBASE="/var/log/mdce"

# CHECKPOINTBASE: The directory in which all checkpoint directories should be
# written. 
# The user the mdce service is run as must have write access to this
# directory.  On the host that runs the job manager, the job manager database
# is written to this directory, and it might require substantial diskspace.
# On the hosts that run the workers, all the data files that are transferred
# with the tasks are written to this directory.
CHECKPOINTBASE="/var/lib/mdce"



########
#
# Job Manager Security
#
########

# SECURITY_LEVEL: Choose the level of security in the cluster.
# The following levels are available:
# Level "0": no security. (Similar to R2009b and earlier releases.) This is the
#            default value.
# Level "1": users are warned when they try to access other users' jobs and
#     tasks, but can still perform all actions.
# Level "2": users need to enter a password to access their jobs and
#     tasks. Other users do not have any access unless specified by the job
#     owners (job property AuthorizedUsers).
# Level "3": same as level "2", but in addition, the jobs and tasks are run on the
#     workers as the user to which they belong.  The password needs to be the
#     system password used to log on to a worker machine ("cluster password").
#     NOTE: This level requires the use of secure communication (see below)
#           and the mdce service being run as user root.
SECURITY_LEVEL="0"

# USE_SECURE_COMMUNICATION: Use secure communication between services.
# By default, job managers and workers communicate over non-secure channels.
# In most cases this is the preferred setting, as either there is no need to
# protect the data or the connection is already protected from unauthorized
# access (e.g., the cluster network is isolated and has no access to the
# Internet).
# Setting this property to "true" results in encrypted communication between
# job managers and workers. This also requires a shared secret on each
# participating host (see SHARED_SECRET_FILE below), and may result in a
# performance degradation as all data is encrypted.
# This must be set to "true" if SECURITY_LEVEL is set to 3.
USE_SECURE_COMMUNICATION="false"

# SHARED_SECRET_FILE: The shared secret file used for secure communication.
# To establish secure connections between job managers and workers, a shared
# secret file is required on all participating hosts. Each service expects to
# find a copy of the same file here at startup. Use the createSharedSecret
# script to create a shared secret file.
# NOTE: secret files contain sensitive data and should be protected against
# unauthorized access. Anyone gaining access to the secret might be able to
# eavesdrop on the connections between services.
# If unset, the shared secret is expected in $CHECKPOINTBASE/security/secret.
SHARED_SECRET_FILE=

# ALLOW_CLIENT_PASSWORD_CACHE: Remember user passwords for future sessions.
# If set to "true" this option allows users to let the MATLAB client remember
# their logons for future client sessions.  Users can still choose to not store
# any information at the password prompt in MATLAB.
ALLOW_CLIENT_PASSWORD_CACHE="true"

# ALLOWED_USERS: A list of users allowed to log on to the job manager.
# The following variable defines a list of users that are allowed to access the
# job manager. Multiple usernames are separated by commas.
# To allow any user to access the job manager, use the keyword "ALL" instead of
# a list of usernames.
ALLOWED_USERS="ALL"



########
#
# Job Manager and Worker Settings
#
########

# DEFAULT_JOB_MANAGER_NAME: The default name of the job manager.  
# When a new job manager is started, it needs to be identified by a name on
# the network, and when a new worker is started, it needs to know the name of
# the job manager it should register with. This is the default job manager
# name used in both of these cases.  
# The default job manager name can be overridden by the -name argument with the
# startjobmanager command, and by the -jobmanager argument with the
# startworker command.
DEFAULT_JOB_MANAGER_NAME="default_jobmanager"

# JOB_MANAGER_HOST: The host on which the job manager lookup process can be
# found.
# If specified, the MATLAB worker processes and the job manager process will
# use unicast to contact the job manager lookup process.  
# If JOB_MANAGER_HOST is unset, the job manager will use unicast to contact
# its own lookup process.  You can then also allow the MATLAB workers to
# unicast to the job manager lookup process by specifying -jobmanagerhost
# with the startworker command.
# If you are certain that your network supports multicast, you can force the
# job manager and the workers to use multicast to locate the job manager
# lookup process by using the -multicast flag with the startjobmanager and
# startworker commands.
JOB_MANAGER_HOST="" 

# JOB_MANAGER_MAXIMUM_MEMORY: The maximum heap size of the job manager java
# process.
JOB_MANAGER_MAXIMUM_MEMORY="512m"

# DEFAULT_WORKER_NAME: The default name of the worker.
# The default worker name can be overridden by the -name argument with the
# startworker command.
# Note that worker names must be unique on each host.  Therefore, you must
# use the -name flag with the startworker command if you want to start more
# than one worker on a single host.
DEFAULT_WORKER_NAME=$HOSTNAME"_worker"

# WORKER_START_TIMEOUT: The time in seconds worker sessions allow for MATLAB 
# to start before detecting a stall. This value should be greater than the 
# time it takes for a MATLAB session to start.
WORKER_START_TIMEOUT="600"

# MATLAB_SHELL: The shell that workers should use in system calls.
# The following variable is used to define the exact shell that should be
# spawned when the MATLAB system command is invoked. For example, you might
# choose to use the /bin/sh shell.
# MATLAB checks internally for the MATLAB_SHELL variable first and, if empty
# or not defined, then checks SHELL. If SHELL is also empty or not defined,
# MATLAB uses /bin/sh. The value of MATLAB_SHELL should be an absolute path,
# e.g., /bin/sh, not simply sh.
# Note that some shells (at least tcsh) might choose to interpret a system 
# command in MATLAB as a request to start up a new login shell, rather than a 
# subshell, which might have consequences for environment variable changes you 
# have made in MATLAB, for example to the PATH environment variable that
# would allow other applications to run.
MATLAB_SHELL=
